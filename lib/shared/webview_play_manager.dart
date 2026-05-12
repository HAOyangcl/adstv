import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:xi/xi.dart';
import 'package:catmovie/shared/enum.dart';

/// WebView播放管理器
/// 使用flutter_inappwebview替代desktop_webview_window和webplayer_embedded
class WebViewPlayManager {
  static final WebViewPlayManager _instance = WebViewPlayManager._internal();
  
  factory WebViewPlayManager() {
    return _instance;
  }
  
  WebViewPlayManager._internal();
  
  InAppWebViewController? _controller;
  HttpServer? _httpServer;
  bool _isInitialized = false;
  
  /// 消息回调
  Function(dynamic)? onMessageCallback;
  
  /// 初始化HTTP服务器
  Future<HttpServer?> initHttpServer({
    required Function(dynamic) onMessage,
  }) async {
    if (_httpServer != null) {
      return _httpServer;
    }
    
    try {
      onMessageCallback = onMessage;
      _httpServer = await HttpServer.bind('localhost', 0);
      debugPrint('HTTP服务器启动成功，端口: ${_httpServer!.port}');
      
      // 监听请求
      _httpServer!.listen((HttpRequest request) {
        _handleRequest(request);
      });
      
      return _httpServer;
    } catch (e) {
      debugPrint('创建HTTP服务器失败: $e');
      return null;
    }
  }
  
  /// 处理HTTP请求
  void _handleRequest(HttpRequest request) {
    String path = request.uri.path;
    
    // 提供iframe.html页面
    if (path == '/assets/iframe.html') {
      String url = request.uri.queryParameters['url'] ?? '';
      String html = _generateIframeHtml(url);
      
      request.response.headers.contentType = ContentType.html;
      request.response.write(html);
      request.response.close();
    } else {
      request.response.statusCode = 404;
      request.response.close();
    }
  }
  
  /// 生成iframe HTML页面
  String _generateIframeHtml(String videoUrl) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>视频播放</title>
  <style>
    body, html {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #000;
    }
    #video-container {
      width: 100%;
      height: 100%;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    iframe {
      width: 100%;
      height: 100%;
      border: none;
    }
    video {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }
  </style>
</head>
<body>
  <div id="video-container">
    <video id="player" controls autoplay></video>
  </div>
  
  <script>
    var currentVideoUrl = '$videoUrl';
    var player = document.getElementById('player');
    
    // 设置视频源
    function setVideoSource(url) {
      currentVideoUrl = url;
      player.src = url;
      player.play();
    }
    
    // 初始化
    if (currentVideoUrl) {
      setVideoSource(currentVideoUrl);
    }
    
    // 暴露给Flutter的方法
    window.setActiveWithPlaylist = function(url) {
      setVideoSource(url);
    };
    
    window.setActionText = function(text) {
      console.log('当前播放: ' + text);
    };
    
    // 监听视频事件
    player.addEventListener('play', function() {
      console.log('视频开始播放');
    });
    
    player.addEventListener('pause', function() {
      console.log('视频暂停');
    });
    
    player.addEventListener('error', function(e) {
      console.error('视频播放错误:', e);
    });
  </script>
</body>
</html>
''';
  }
  
  /// 生成播放器URL
  String generatePlayerUrl(IWebPlayerEmbeddedType type, String url) {
    // 对于m3u8等格式，直接返回URL，由video标签处理
    return url;
  }
  
  /// 检查服务器是否运行
  Future<bool> checkRunning() async {
    return _httpServer != null;
  }
  
  /// 创建并显示WebView窗口
  Future<void> showWebView({
    required String url,
    required String title,
    required BuildContext context,
    List<String>? playlist,
    Function(String)? onUrlChanged,
  }) async {
    if (!_isInitialized) {
      await _initialize();
    }
    
    // 在对话框中显示WebView
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  useHybridComposition: true,
                  safeBrowsingEnabled: false,
                ),
                onWebViewCreated: (controller) {
                  _controller = controller;
                  debugPrint('WebView创建成功');
                  
                  // 注入播放列表脚本
                  if (playlist != null && playlist.isNotEmpty) {
                    _injectPlaylistScript(playlist);
                  }
                },
                onLoadStart: (controller, url) {
                  debugPrint('开始加载: $url');
                },
                onLoadStop: (controller, url) async {
                  debugPrint('加载完成: $url');
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    debugPrint('页面加载完成');
                  }
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  String newUrl = navigationAction.request.url?.toString() ?? '';
                  debugPrint('URL变更: $newUrl');
                  
                  // 通知URL变更
                  if (onUrlChanged != null) {
                    onUrlChanged(newUrl);
                  }
                  
                  return NavigationActionPolicy.ALLOW;
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint('WebView Console: ${consoleMessage.message}');
                },
              ),
              // 关闭按钮
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    dispose();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 注入播放列表脚本
  void _injectPlaylistScript(List<String> playlist) {
    if (_controller == null) return;
    
    String script = '''
      window.playlist = ${jsonEncode(playlist)};
      window.setActiveWithPlaylist = function(url) {
        console.log('切换到: ' + url);
      };
      window.setActionText = function(text) {
        console.log('当前: ' + text);
      };
    ''';
    
    _controller!.evaluateJavascript(source: script);
  }
  
  /// 执行JavaScript
  Future<dynamic> evaluateJavaScript(String javascript) async {
    if (_controller == null) return null;
    return await _controller!.evaluateJavascript(source: javascript);
  }
  
  /// 初始化
  Future<void> _initialize() async {
    if (!kIsWeb && Platform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
    _isInitialized = true;
  }
  
  /// 释放资源
  void dispose() {
    _controller?.dispose();
    _controller = null;
    
    if (_httpServer != null) {
      try {
        _httpServer!.close();
        _httpServer = null;
        debugPrint('HTTP服务器已关闭');
      } catch (e) {
        debugPrint('关闭HTTP服务器失败: $e');
      }
    }
    
    _isInitialized = false;
    onMessageCallback = null;
  }
}

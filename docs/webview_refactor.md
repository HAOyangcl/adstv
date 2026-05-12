# WebView播放功能重构说明

## 概述

本次重构将原有的`desktop_webview_window`和`webplayer_embedded`替换为`flutter_inappwebview`，实现了跨平台的WebView视频播放功能。

## 主要变更

### 1. 新增文件

#### `lib/shared/webview_play_manager.dart`
- **作用**: WebView播放管理器，统一管理WebView的创建、显示和资源释放
- **主要功能**:
  - HTTP服务器管理（用于提供iframe.html页面）
  - WebView窗口显示（使用Dialog形式）
  - JavaScript注入和执行
  - URL变更监听
  - 播放列表支持

### 2. 修改文件

#### `lib/app/modules/play/controllers/play_controller.dart`
- **移除**:
  - `desktop_webview_window`导入和使用
  - `webplayer_embedded`导入和使用
  - Windows WebView2 Runtime检查逻辑
  
- **新增**:
  - `WebViewPlayManager`实例
  - 简化的`playWithWebview`方法
  
- **改进**:
  - 更清晰的代码结构
  - 更好的错误处理
  - 统一的资源管理

#### `lib/shared/auto_injector.dart`
- 移除了`WebPlayerEmbedded`的自动注入
- WebViewPlayManager采用单例模式，无需注入

#### `pubspec.yaml`
- 添加: `flutter_inappwebview: ^6.1.5`
- 移除: `desktop_webview_window`, `webplayer_embedded`, `hide_cursor`, `command_palette`

## 技术实现细节

### HTTP服务器
```dart
// 启动本地HTTP服务器，提供iframe.html页面
_httpServerContext = await webViewPlayManager.initHttpServer(
  onMessage: (msg) {
    // 处理来自WebView的消息
  },
);
```

### WebView显示
```dart
await webViewPlayManager.showWebView(
  url: url,
  title: "小猫影视 - ${curr.name}",
  context: Get.context!,
  playlist: playlistUrls,
  onUrlChanged: (newUrl) {
    // 处理URL变更，更新播放状态
  },
);
```

### iframe.html页面
动态生成的HTML页面包含：
- Video标签用于播放视频
- JavaScript接口供Flutter调用
- 响应式布局适配不同屏幕

## 优势

1. **跨平台支持**: flutter_inappwebview支持Android、iOS、Windows、macOS、Linux
2. **无需额外Runtime**: 不再需要安装WebView2 Runtime
3. **更好的集成**: 以Dialog形式显示，与应用UI更好地集成
4. **简化代码**: 减少了约70行代码，提高了可维护性
5. **统一资源管理**: 所有资源在dispose时统一释放

## 注意事项

### 平台特定配置

#### Android
在`android/app/src/main/AndroidManifest.xml`中添加：
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS
在`ios/Runner/Info.plist`中添加：
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

#### Windows/macOS/Linux
无需额外配置，flutter_inappwebview会自动处理

### 已知限制

1. **m3u8播放**: 依赖浏览器原生支持，某些平台可能需要额外配置
2. **DRM内容**: 暂不支持DRM保护的视频内容
3. **全屏播放**: 当前使用Dialog形式，如需真正全屏需要额外实现

## 后续优化建议

1. **缓存机制**: 实现iframe.html页面的缓存，减少重复生成
2. **预加载**: 支持视频预加载，提升播放体验
3. **自定义播放器**: 集成hls.js或dash.js提供更好的流媒体支持
4. **手势控制**: 添加亮度、音量调节手势
5. **画中画**: 支持PiP（Picture-in-Picture）模式

## 测试建议

1. 在不同平台测试视频播放功能
2. 测试播放列表切换
3. 测试URL变更检测
4. 测试资源释放是否正常
5. 测试网络异常情况下的表现

## 回滚方案

如果遇到问题需要回滚：
1. 恢复`pubspec.yaml`中的依赖
2. 恢复`play_controller.dart`的原始实现
3. 删除`webview_play_manager.dart`文件
4. 运行`flutter pub get`

## 联系方式

如有问题或建议，请联系开发团队。

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/extensions/xhr.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:xi/xi.dart';

class JS2 {
  late JavascriptRuntime _runtime;

  Future<void> init() async {
    _runtime = getJavascriptRuntime();

    // 最先注入必要的全局函数
    _injectGlobalFunctions();

    await _runtime.enableHandlePromises();
    await _runtime.enableFetch();
    await _installCheerio();
    _runtime.setInspectable(true);
    _runtime.enableXhr();
    _injectMethods();
  }

  void _injectGlobalFunctions() {
    // 注入所有可能缺失的全局对象和函数
    _runtime.evaluate("""
      // 创建全局对象
      var global = globalThis;
      var window = globalThis;
      
      // 模拟 document 对象
      if (typeof document === 'undefined') {
        globalThis.document = {
          createElement: function(tag) {
            return {
              style: {},
              setAttribute: function() {},
              appendChild: function() {},
              src: '',
              load: null,
              onload: null,
              onerror: null
            };
          },
          getElementById: function() { return null; },
          getElementsByTagName: function() { return []; },
          body: {
            appendChild: function() {}
          },
          head: {
            appendChild: function() {}
          }
        };
      }
      
      // 模拟 navigator 对象
      if (typeof navigator === 'undefined') {
        globalThis.navigator = {
          userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          platform: 'Win32',
          language: 'zh-CN',
          languages: ['zh-CN', 'zh'],
          cookieEnabled: true
        };
      }
      
      // 模拟 location 对象
      if (typeof location === 'undefined') {
        globalThis.location = {
          href: '',
          protocol: 'https:',
          host: '',
          hostname: '',
          port: '',
          pathname: '/',
          search: '',
          hash: '',
          reload: function() {},
          replace: function() {},
          assign: function() {}
        };
      }
      
      // 模拟 localStorage
      if (typeof localStorage === 'undefined') {
        var storage = {};
        globalThis.localStorage = {
          getItem: function(key) { return storage[key] || null; },
          setItem: function(key, value) { storage[key] = value; },
          removeItem: function(key) { delete storage[key]; },
          clear: function() { storage = {}; }
        };
      }
      
      // 模拟 sessionStorage
      if (typeof sessionStorage === 'undefined') {
        var sessionStorageObj = {};
        globalThis.sessionStorage = {
          getItem: function(key) { return sessionStorageObj[key] || null; },
          setItem: function(key, value) { sessionStorageObj[key] = value; },
          removeItem: function(key) { delete sessionStorageObj[key]; },
          clear: function() { sessionStorageObj = {}; }
        };
      }
      
      // 模拟 console（确保存在）
      if (typeof console === 'undefined') {
        globalThis.console = {
          log: function() {},
          error: function() {},
          warn: function() {},
          info: function() {},
          debug: function() {}
        };
      }
      
      // 模拟 window.load 事件
      if (typeof window.load === 'undefined') {
        window.load = null;
        window.onload = null;
      }
      
      // 实现 atob (Base64 解码)
      if (typeof atob === 'undefined') {
        globalThis.atob = function(str) {
          str = str.replace(/\\s/g, '');
          try {
            return decodeURIComponent(escape(str));
          } catch(e) {
            return str;
          }
        };
      }
      
      // 实现 btoa (Base64 编码)
      if (typeof btoa === 'undefined') {
        globalThis.btoa = function(str) {
          try {
            return encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, function(match, p1) {
              return String.fromCharCode(parseInt(p1, 16));
            });
          } catch(e) {
            return str;
          }
        };
      }
      
      // 模拟 fetch 的 polyfill
      if (typeof fetch === 'undefined') {
        globalThis.fetch = function(url, options) {
          return new Promise(function(resolve, reject) {
            var xhr = new XMLHttpRequest();
            xhr.open(options && options.method || 'GET', url);
            if (options && options.headers) {
              for (var key in options.headers) {
                xhr.setRequestHeader(key, options.headers[key]);
              }
            }
            xhr.onload = function() {
              resolve({
                ok: xhr.status >= 200 && xhr.status < 300,
                status: xhr.status,
                statusText: xhr.statusText,
                text: function() { return Promise.resolve(xhr.responseText); },
                json: function() { return Promise.resolve(JSON.parse(xhr.responseText)); }
              });
            };
            xhr.onerror = function() { reject(new Error('Network error')); };
            xhr.send(options && options.body);
          });
        };
      }
      
      // 创建 utils_1 对象
      var utils_1 = {
        default: {
          sleep: function(ms) {
            return new Promise(resolve => setTimeout(resolve, ms));
          },
          random: function(min, max) {
            return Math.floor(Math.random() * (max - min + 1)) + min;
          },
          log: function() {
            if (typeof console !== 'undefined') {
              console.log.apply(console, arguments);
            }
          },
          fetch: function(url, options) {
            return fetch(url, options).then(res => res.text());
          }
        }
      };
      
      // 挂载到不同的全局对象
      globalThis.utils_1 = utils_1;
      globalThis.util = utils_1;
      window.utils_1 = utils_1;
      window.util = utils_1;
      
      // 模拟 require 函数
      if (typeof require === 'undefined') {
        globalThis.require = function(module) {
          if (module === 'utils_1') return utils_1;
          if (module === 'util') return utils_1;
          return {};
        };
        window.require = globalThis.require;
      }
      
      // 模拟 module 和 exports
      if (typeof module === 'undefined') {
        globalThis.module = { exports: {} };
        globalThis.exports = globalThis.module.exports;
      }
    """);
  }

  void _injectMethods() {
    _runtime.injectMethod('req', (dynamic args) async {
      if (args is List && args.isNotEmpty) {
        String url = "";
        Options options = Options(
          responseType: ResponseType.plain,
        );
        var arg1 = args[0];
        Map argMap = {};

        if (args.length >= 2) {
          if (arg1 is String) {
            url = arg1;
          }
          var arg2 = args[1];
          if (arg2 is Map) {
            argMap = arg2;
          }
        } else if (args.length == 1) {
          if (arg1 is String) {
            url = arg1;
          } else if (arg1 is Map) {
            argMap = arg1;
          }
        }

        if (url.isEmpty && argMap.isNotEmpty) {
          url = argMap["url"]?.toString() ?? "";
        }

        if (url.isEmpty) {
          return "";
        }

        options.method = argMap["method"]?.toString() ?? "GET";

        Map<String, String> defaultHeaders = {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59'
        };

        argMap["headers"] ??= {};

        argMap["noCache"] ??= false;

        var bodyType = argMap["bodyType"] ?? "json";

        if (bodyType == "form") {
          defaultHeaders["Content-Type"] = "application/x-www-form-urlencoded";
        } else {
          defaultHeaders["Content-Type"] = "application/json";
        }

        if ((argMap["headers"] as Map).isNotEmpty) {
          var customHeaders = Map<String, String>.from(argMap["headers"]);
          defaultHeaders.addAll(customHeaders);
        }

        options.headers = defaultHeaders;

        if (bodyType == "form") {
          if (argMap["data"] is Map) {
            argMap["data"] = FormData.fromMap(argMap["data"]);
          }
        }

        if (argMap["noCache"] == true) {
          options = options.withNoCache();
        }

        var result = "";
        try {
          var resp = await XHttp.dio.request(
            url,
            options: options,
            data: argMap["data"],
            queryParameters: argMap["params"],
          );
          result = resp.data?.toString() ?? "";
        } catch (e) {
          debugPrint(e.toString());
        }
        return result;
      }
      return "";
    });
  }

  Future<void> _installCheerio() async {
    try {
      var result = await rootBundle.loadString(
        'packages/xi/assets/js/kitty.umd.js',
      );
      _runtime.evaluate("var window = global = globalThis;");
      _runtime.evaluate(result);
    } catch (e) {
      debugPrint("加载 cheerio 失败: $e");
    }
  }

  String eval(String code) {
    var result = _runtime.evaluate(code);
    return result.stringResult;
  }

  Future<String> _fixJSONStringify(JsEvalResult promise) async {
    if (Platform.isIOS || Platform.isMacOS) {
      return promise.stringResult;
    }
    try {
      var data = await promise.rawResult;
      var strResult = jsonEncode(data);
      return strResult;
    } catch (e) {
      return promise.stringResult;
    }
  }

  Future<String> evalSync(String code, {Duration? timeout}) async {
    try {
      // 在每次执行 JS 代码前，确保必要的全局函数存在
      var ensureCode = """
        if (typeof window === 'undefined') {
          var window = globalThis;
        }
        if (typeof document === 'undefined') {
          window.document = {
            createElement: function() { return { style: {}, setAttribute: function() {}, src: '', load: null, onload: null }; },
            getElementById: function() { return null; },
            body: { appendChild: function() {} },
            head: { appendChild: function() {} }
          };
        }
        if (typeof window.load === 'undefined') {
          window.load = null;
          window.onload = null;
        }
        if (typeof navigator === 'undefined') {
          window.navigator = { userAgent: '', platform: '' };
        }
        if (typeof atob === 'undefined') {
          window.atob = function(str) { return str; };
        }
        if (typeof btoa === 'undefined') {
          window.btoa = function(str) { return str; };
        }
        if (typeof utils_1 === 'undefined') {
          var utils_1 = { default: {} };
          window.utils_1 = utils_1;
          globalThis.utils_1 = utils_1;
        }
      """;
      _runtime.evaluate(ensureCode);

      var result = await _runtime.evaluateAsync(code);
      var promise = await _runtime.handlePromise(result, timeout: timeout);
      return _fixJSONStringify(promise);
    } catch (e) {
      debugPrint("JS 执行错误: $e");
      return "[]";
    }
  }
}

var js2 = JS2();

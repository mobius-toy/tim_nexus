import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

import '../../../core/services/tim_gateway.dart';
import '../../../core/services/local_web_server.dart';

class WaveEditorController extends ChangeNotifier {
  WaveEditorController({required this.gateway});

  final TimGateway gateway;

  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _useFallback = false;
  bool _useEmbedded = false;
  bool _jsChannelSetup = false;

  // Getters
  WebViewController? get controller => _controller;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get useFallback => _useFallback;
  bool get useEmbedded => _useEmbedded;
  bool get jsChannelSetup => _jsChannelSetup;

  void initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((message) {
        print('WebView Console: [${message.level}] ${message.message}');
      })
      ..setUserAgent(
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15',
      )
      ..clearCache()
      ..clearLocalStorage()
      ..addJavaScriptChannel(
        'TimRhythmBridge',
        onMessageReceived: (JavaScriptMessage message) {
          print('收到 JavaScript Channel 消息: ${message.message}');
          _handleWebMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('WebView: 开始加载嵌入版本');
            _isLoading = true;
            _errorMessage = null;
            notifyListeners();
          },
          onPageFinished: (String url) {
            print('WebView: 页面加载完成 - $url');
            _isLoading = false;
            notifyListeners();
          },
          onSslAuthError: (request) {
            print('WebView onSslAuthError');
          },
          onHttpError: (error) {
            print('WebView onHttpError, $error');
          },
          onWebResourceError: (WebResourceError error) {
            print('嵌入版本错误详情:');
            print('  错误代码: ${error.errorCode}');
            print('  错误描述: ${error.description}');
            print('  错误类型: ${error.errorType}');
            print('  URL: ${error.url}');
            print('  是否主帧: ${error.isForMainFrame}');

            String errorMessage = '嵌入版本加载失败\n\n';
            errorMessage += '错误代码: ${error.errorCode}\n';
            errorMessage += '错误类型: ${error.errorType}\n\n';
            errorMessage += '将尝试使用备选方案。';

            _isLoading = false;
            _errorMessage = errorMessage;
            notifyListeners();
          },
        ),
      );

    // 直接加载嵌入的 Next.js 版本
    loadEmbeddedWeb();
  }

  Future<void> loadEmbeddedWeb() async {
    try {
      print('启动本地 Web 服务器...');

      // 启动本地服务器
      await LocalWebServer.startServer();

      // 等待服务器启动
      await Future.delayed(const Duration(milliseconds: 500));

      final String localUrl = LocalWebServer.baseUrl;
      print('加载本地 URL: $localUrl');

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _controller?.loadRequest(
        Uri.parse('$localUrl?t=${DateTime.now().millisecondsSinceEpoch}'),
      );

      _useEmbedded = true;
      _useFallback = false;
      _errorMessage = null;
      notifyListeners();

      print('嵌入 Web 应用加载请求已发送');
    } catch (e) {
      print('加载嵌入 Web 应用失败: $e');
      _errorMessage = '无法加载嵌入的 Web 应用: $e\n\n将尝试使用备选方案。';
      notifyListeners();
    }
  }

  void _setupJavaScriptChannels() async {
    // 防止重复注册 JavaScript 通道
    if (_jsChannelSetup) {
      print('JavaScript Channel 已设置，跳过重复注册');
      return;
    }

    try {
      // 添加 JavaScript 通道用于与 Web 页面通信
      await _controller?.addJavaScriptChannel(
        'TimRhythmBridge',
        onMessageReceived: (JavaScriptMessage message) {
          print('收到 JavaScript Channel 消息: ${message.message}');
          _handleWebMessage(message.message);
        },
      );

      _jsChannelSetup = true;
      print('JavaScript Channel 注册成功: TimRhythmBridge');
    } catch (e) {
      print('JavaScript Channel 注册失败: $e');
      // 如果注册失败，重置标志以便重试
      _jsChannelSetup = false;
    }
  }

  Future<void> _handleWebMessage(String message) async {
    print('receive web message: $message');
    try {
      final data = jsonDecode(message);
      final method = data['method'] as String;
      final params = data['params'] as Map<String, dynamic>? ?? {};
      final messageId = data['messageId'] as String;

      Map<String, dynamic> result = {};

      switch (method) {
        case 'vibrate':
          final intensity = params['intensity'] as double? ?? 0.0;
          if (intensity > 0) {
            // 发送震动数据
            await gateway.sendWaveform([(intensity * 100).toInt()]);
            result = {'success': true};
          } else {
            // 停止震动
            await gateway.stopPlayback();
            result = {'success': true};
          }
          break;

        default:
          result = {'error': 'Unknown method: $method'};
      }
    } catch (e) {
      // 发送错误响应
      print('handle web message failed. $e, $message');
    }
  }

  void reload() {
    _controller?.reload();
  }

  @override
  void dispose() {
    LocalWebServer.stopServer();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../../core/services/tim_gateway.dart';
import '../../../core/services/local_web_server.dart';
import '../../../shared/widgets/ambient_background.dart';

class WaveEditorScreen extends StatefulWidget {
  const WaveEditorScreen({super.key, this.deviceId});

  static const String routeName = '/wave';

  final String? deviceId;

  @override
  State<WaveEditorScreen> createState() => _WaveEditorScreenState();
}

class _WaveEditorScreenState extends State<WaveEditorScreen> {
  late final WebViewController _controller;
  final TimGateway _gateway = TimGateway();
  bool _isLoading = true;
  String? _errorMessage;
  bool _useFallback = false;
  bool _useEmbedded = false; // 新增：标记是否使用嵌入资源
  bool _jsChannelSetup = false; // 新增：标记 JavaScript Channel 是否已设置

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    LocalWebServer.stopServer();
    super.dispose();
  }

  void _initializeWebView() {
    // 默认使用简单测试页面进行调试
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnConsoleMessage((message) {
        print('WebView Console: [${message.level}] ${message.message}');
      })
      ..setUserAgent(
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('WebView: 开始加载嵌入版本');
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            print('WebView: 页面加载完成 - $url');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }

            _setupJavaScriptChannels();
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

            setState(() {
              _isLoading = false;
              _errorMessage = errorMessage;
            });

            // 自动回退到本地版本
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && _errorMessage != null) {
                _loadFallbackPage();
              }
            });
          },
        ),
      );

    // 直接加载嵌入的 Next.js 版本
    _loadEmbeddedWeb();
  }

  Future<void> _loadFallbackPage() async {
    try {
      final String htmlContent = await rootBundle.loadString('assets/webview_fallback.html');
      await _controller.loadHtmlString(htmlContent);
      setState(() {
        _useFallback = true;
        _useEmbedded = false;
        _isLoading = false;
        _errorMessage = null;
      });
      _setupJavaScriptChannels();
    } catch (e) {
      setState(() {
        _errorMessage = '无法加载本地页面: $e';
      });
    }
  }

  Future<void> _loadEmbeddedWeb() async {
    try {
      print('启动本地 Web 服务器...');

      // 启动本地服务器
      await LocalWebServer.startServer();

      // 等待服务器启动
      await Future.delayed(const Duration(milliseconds: 500));

      final String localUrl = LocalWebServer.baseUrl;
      print('加载本地 URL: $localUrl');

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _controller.loadRequest(Uri.parse(localUrl));

      if (mounted) {
        setState(() {
          _useEmbedded = true;
          _useFallback = false;
          _errorMessage = null;
        });
      }

      print('嵌入 Web 应用加载请求已发送');
    } catch (e) {
      print('加载嵌入 Web 应用失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '无法加载嵌入的 Web 应用: $e\n\n将尝试使用备选方案。';
        });
      }
    }
  }

  void _setupJavaScriptChannels() {
    // 防止重复注册 JavaScript 通道
    if (_jsChannelSetup) {
      print('JavaScript Channel 已设置，跳过重复注册');
      return;
    }

    try {
      // 添加 JavaScript 通道用于与 Web 页面通信
      _controller.addJavaScriptChannel(
        'timRhythmBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleWebMessage(message.message);
        },
      );

      _jsChannelSetup = true;
      print('JavaScript Channel 注册成功');
    } catch (e) {
      print('JavaScript Channel 注册失败: $e');
      // 如果注册失败，重置标志以便重试
      _jsChannelSetup = false;
    }
  }

  Future<void> _handleWebMessage(String message) async {
    try {
      final data = jsonDecode(message);
      final method = data['method'] as String;
      final params = data['params'] as Map<String, dynamic>? ?? {};
      final messageId = data['messageId'] as int;

      Map<String, dynamic> result = {};

      switch (method) {
        case 'initialize':
          await _gateway.ensureInitialized();
          result = {'success': true};
          break;

        case 'scanDevices':
          final devices = await _gateway.scanDevices(
            timeout: Duration(milliseconds: params['timeout'] ?? 12000),
            withNames: List<String>.from(params['withNames'] ?? []),
          );
          result = {
            'devices': devices
                .map(
                  (d) => {
                    'id': d.id,
                    'name': d.name,
                    'isConnected': d.isConnected,
                  },
                )
                .toList(),
          };
          break;

        case 'stopScan':
          await _gateway.stopScan();
          result = {'success': true};
          break;

        case 'connectDevice':
          final deviceId = params['deviceId'] as String;
          final success = await _gateway.connectToDevice(deviceId);
          result = {'success': success};
          break;

        case 'disconnect':
          await _gateway.disconnect();
          result = {'success': true};
          break;

        case 'sendWaveform':
          final waveform = List<int>.from(params['waveform'] ?? []);
          await _gateway.sendWaveform(waveform);
          result = {'success': true};
          break;

        case 'playWaveform':
          await _gateway.playWaveform();
          result = {'success': true};
          break;

        case 'stopPlayback':
          await _gateway.stopPlayback();
          result = {'success': true};
          break;

        case 'getDeviceStatus':
          result = {
            'state': _gateway.currentState.toString(),
            'isInitialized': _gateway.isInitialized,
            'isConnected': _gateway.currentState == TimState.connected,
            'hasDevice': _gateway.currentState == TimState.connected,
          };
          break;

        default:
          result = {'error': 'Unknown method: $method'};
      }

      // 发送响应回 Web 页面
      await _controller.runJavaScript('''
        window.dispatchEvent(new CustomEvent('tim_rhythm_response', {
          detail: {
            messageId: $messageId,
            result: ${jsonEncode(result)}
          }
        }));
      ''');
    } catch (e) {
      // 发送错误响应
      final messageId = jsonDecode(message)['messageId'] as int;
      await _controller.runJavaScript('''
        window.dispatchEvent(new CustomEvent('tim_rhythm_response', {
          detail: {
            messageId: $messageId,
            error: '${e.toString()}'
          }
        }));
      ''');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: '帮助',
          ),
        ],
      ),
      body: AmbientBackground(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在加载波形编辑器...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    if (_useEmbedded) {
      return '波形工作台 (Next.js)';
    } else if (_useFallback) {
      return '波形工作台 (本地)';
    } else {
      return '波形工作台';
    }
  }

  void _showHelpDialog(BuildContext context) {
    final currentMode = _useEmbedded ? "Next.js" : (_useFallback ? "本地页面" : "未知");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('波形工作台帮助'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前模式: $currentMode'),
            const SizedBox(height: 16),
            const Text('波形工作台功能：'),
            const SizedBox(height: 8),
            const Text('• 波形编辑和可视化'),
            const Text('• 预设波形模板'),
            const Text('• 实时播放控制'),
            const Text('• 蓝牙设备连接'),
            const Text('• 波形数据传输'),
            const SizedBox(height: 8),
            const Text('技术栈：'),
            const SizedBox(height: 4),
            const Text('• Next.js + shadcn/ui'),
            const Text('• TypeScript + Tailwind CSS'),
            const Text('• Web Bluetooth API'),
            const SizedBox(height: 8),
            const Text('如果遇到问题，请尝试刷新页面。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/services/tim_gateway.dart';
import '../../../shared/widgets/ambient_background.dart';
import '../controller/wave_editor_controller.dart';

class WaveEditorScreen extends StatelessWidget {
  const WaveEditorScreen({super.key, this.deviceId});

  static const String routeName = '/wave';

  final String? deviceId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = WaveEditorController(
          gateway: context.read<TimGateway>(),
        );
        // 在创建后立即初始化 WebView
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.initializeWebView();
        });
        return controller;
      },
      child: const _WaveEditorView(),
    );
  }
}

class _WaveEditorView extends StatelessWidget {
  const _WaveEditorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('波形工作台'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final controller = context.read<WaveEditorController>();
              if (controller.controller != null) {
                controller.reload();
              }
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
        child: Consumer<WaveEditorController>(
          builder: (context, controller, child) {
            return Stack(
              children: [
                if (controller.controller != null) WebViewWidget(controller: controller.controller!),
                if (controller.isLoading || controller.controller == null)
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
            );
          },
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final controller = context.read<WaveEditorController>();
    final currentMode = controller.useEmbedded ? "Next.js" : (controller.useFallback ? "本地页面" : "未知");

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

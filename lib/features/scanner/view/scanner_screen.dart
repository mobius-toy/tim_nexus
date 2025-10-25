import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim/tim.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/services/tim_gateway.dart';
import '../../../shared/widgets/ambient_background.dart';
import '../../session/view/device_session_screen.dart';
import '../controller/scanner_controller.dart';
import '../../../core/utils/color_adapter.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  static const String routeName = '/scanner';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ScannerController>(
      create: (context) {
        final controller = ScannerController(context.read<TimGateway>());
        controller.initialize();
        return controller;
      },
      child: const _ScannerView(),
    );
  }
}

class _ScannerView extends StatelessWidget {
  const _ScannerView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备控制中心'),
      ),
      body: AmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StateBanner(textTheme: textTheme),
                const SizedBox(height: 16),
                _ScannerControls(),
                const SizedBox(height: 12),
                Expanded(
                  child: Consumer<ScannerController>(
                    builder: (context, controller, _) {
                      if (controller.devices.isEmpty) {
                        return _EmptyPlaceholder(isScanning: controller.isScanning, error: controller.error);
                      }
                      return ListView.separated(
                        itemBuilder: (context, index) {
                          final device = controller.devices[index];
                          return _DeviceCard(device: device);
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: controller.devices.length,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StateBanner extends StatelessWidget {
  const _StateBanner({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final state = context.select<ScannerController, TimState>((controller) => controller.state);
    final description = switch (state) {
      TimState.on => '蓝牙已就绪，可以开始扫描设备。',
      TimState.off => '蓝牙已关闭，请开启蓝牙以继续。',
      TimState.unavailable => '设备暂不支持蓝牙功能。',
      TimState.unauthorized => '蓝牙权限未授予，请前往设置开启。',
      TimState.unknown => '正在获取蓝牙状态...',
    };

    final color = switch (state) {
      TimState.on => const Color(0xFF00F5C3),
      TimState.off => Colors.orangeAccent,
      TimState.unauthorized => Colors.amber,
      _ => Colors.white70,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.podcasts, color: color),
                const SizedBox(width: 10),
                Text('适配器状态', style: textTheme.titleLarge?.copyWith(color: color)),
              ],
            ),
            const SizedBox(height: 10),
            Text(description, style: textTheme.bodyLarge?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _ScannerControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ScannerController>();
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.isScanning ? null : controller.startScan,
            icon: const Icon(Icons.radar),
            label: Text(controller.isScanning ? '扫描中...' : '开始扫描'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: controller.isScanning ? controller.stopScan : null,
          icon: const Icon(Icons.stop_circle),
          label: const Text('停止'),
        ),
      ],
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.isScanning, this.error});

  final bool isScanning;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.amber, size: 48),
            const SizedBox(height: 12),
            Text('扫描失败', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(error!, style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sensors, color: Colors.white.withAlphaCompat(0.6), size: 54),
          const SizedBox(height: 12),
          Text(
            isScanning ? '正在搜寻附近的 TIM 设备...' : '点击“开始扫描”寻找设备',
            style: textTheme.bodyLarge?.copyWith(color: Colors.white60),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device});

  final TimDevice device;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRouter.sessionRoute,
          arguments: DeviceSessionArguments(deviceId: device.id),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x3320FFE6),
              Color(0x1100F5C3),
            ],
          ),
          border: Border.all(color: Colors.white.withAlphaCompat(0.08)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  device.name.isNotEmpty ? device.name : '未命名设备',
                  style: textTheme.titleLarge,
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              device.id,
              style: textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Badge(
                  icon: Icons.battery_charging_full,
                  label: '${device.batteryValue}%',
                ),
                const SizedBox(width: 12),
                _Badge(
                  icon: Icons.wifi_tethering,
                  label: 'RSSI ${device.rssiValue}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withAlphaCompat(0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

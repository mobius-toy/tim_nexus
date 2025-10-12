import 'package:flutter/material.dart';

import '../../../shared/widgets/ambient_background.dart';

class DeviceSessionArguments {
  const DeviceSessionArguments({required this.deviceId});

  final String deviceId;
}

class DeviceSessionScreen extends StatelessWidget {
  const DeviceSessionScreen({super.key, this.deviceId});

  static const String routeName = '/session';

  final String? deviceId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备详情'),
      ),
      body: AmbientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.devices_other, color: Colors.white.withValues(alpha: 0.6), size: 84),
                const SizedBox(height: 24),
                Text(
                  deviceId != null ? '设备 ID: $deviceId' : '未指定设备',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  '这里将呈现连接状态、实时遥测以及 OTA / 波形控制。后续步骤中会注入完整逻辑。',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回扫描'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

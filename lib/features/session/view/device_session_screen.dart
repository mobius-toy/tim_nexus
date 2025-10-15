import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim/tim.dart';

import '../../../core/services/tim_gateway.dart';
import '../../../shared/widgets/ambient_background.dart';
import '../../wave_editor/view/wave_editor_screen.dart';
import '../controller/device_session_controller.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备详情'),
        actions: [
          IconButton(
            tooltip: '波形工作台',
            icon: const Icon(Icons.waves),
            onPressed: () => Navigator.of(context).pushNamed(WaveEditorScreen.routeName),
          ),
        ],
      ),
      body: deviceId == null
          ? const _MissingDeviceView()
          : ChangeNotifierProvider(
              create: (context) => DeviceSessionController(
                gateway: context.read<TimGateway>(),
                deviceId: deviceId!,
              )..initialize(),
              child: const _DeviceSessionView(),
            ),
    );
  }
}

class _DeviceSessionView extends StatelessWidget {
  const _DeviceSessionView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DeviceSessionController>();
    final device = controller.device;
    final textTheme = Theme.of(context).textTheme;

    return AmbientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SessionHeader(status: controller.status, device: device, error: controller.errorMessage),
              const SizedBox(height: 16),
              if (device != null) ...[
                _DeviceInfoCard(device: device, controller: controller),
                const SizedBox(height: 16),
                _MotorControlCard(controller: controller),
                const SizedBox(height: 16),
              ],
              SizedBox(
                height: 300, // 固定日志区域高度
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('实时日志', style: textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Expanded(
                          child: controller.logs.isEmpty
                              ? const Center(
                                  child: Text('暂无日志', style: TextStyle(color: Colors.white54)),
                                )
                              : ListView.builder(
                                  reverse: true,
                                  itemCount: controller.logs.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        controller.logs[index],
                                        style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({required this.status, required this.device, this.error});

  final DeviceSessionStatus status;
  final TimDevice? device;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(device?.name.isNotEmpty == true ? device!.name : '未知设备', style: textTheme.headlineSmall),
                    Spacer(),
                    _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(device?.id ?? '设备未连接', style: textTheme.bodyMedium?.copyWith(color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: status == DeviceSessionStatus.connected
                      ? null
                      : () => context.read<DeviceSessionController>().reconnect(),
                  icon: const Icon(Icons.link),
                  label: const Text('连接'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: status == DeviceSessionStatus.connected
                      ? () => context.read<DeviceSessionController>().disconnect()
                      : null,
                  icon: const Icon(Icons.link_off),
                  label: const Text('断开'),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: textTheme.bodySmall?.copyWith(color: Colors.amberAccent)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard({required this.device, required this.controller});

  final TimDevice device;
  final DeviceSessionController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('设备信息', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            _InfoRow(label: 'MAC 地址', value: device.mac.isNotEmpty ? device.mac : '--'),
            _InfoRow(label: '固件版本', value: device.fv.isNotEmpty ? device.fv : '--'),
            _InfoRow(label: '产品 ID', value: device.pid.isNotEmpty ? device.pid : '--'),
            _InfoRow(label: '上次断开原因', value: controller.lastDisconnectReason?.description ?? '--'),
            const SizedBox(height: 16),
            Row(
              children: [
                _MetricBadge(
                  icon: Icons.battery_charging_full,
                  label: '电量',
                  value: controller.batteryLevel != null ? '${controller.batteryLevel}%' : '--',
                ),
                const SizedBox(width: 12),
                _MetricBadge(
                  icon: Icons.wifi_tethering,
                  label: 'RSSI',
                  value: controller.rssi != null ? '${controller.rssi} dBm' : '--',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MotorControlCard extends StatelessWidget {
  const _MotorControlCard({required this.controller});

  final DeviceSessionController controller;

  @override
  Widget build(BuildContext context) {
    final isConnected = controller.status == DeviceSessionStatus.connected;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('马达控制', style: textTheme.titleLarge),
                Text(isConnected ? '实时推送至设备' : '连接后可用', style: textTheme.bodySmall?.copyWith(color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: controller.motorIntensity,
              onChanged: isConnected ? (value) => context.read<DeviceSessionController>().playMotor(value) : null,
              min: 0,
              max: 1,
              divisions: 20,
              label: '${(controller.motorIntensity * 100).round()}%',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: isConnected ? () => context.read<DeviceSessionController>().stopMotor() : null,
                  icon: const Icon(Icons.stop_circle),
                  label: const Text('停止'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Text('$label  $value', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final DeviceSessionStatus status;

  Color get _color {
    switch (status) {
      case DeviceSessionStatus.connected:
        return const Color(0xFF00F5C3);
      case DeviceSessionStatus.connecting:
      case DeviceSessionStatus.disconnecting:
        return Colors.amberAccent;
      case DeviceSessionStatus.error:
        return Colors.redAccent;
      case DeviceSessionStatus.disconnected:
      case DeviceSessionStatus.idle:
        return Colors.white30;
    }
  }

  String get _label {
    switch (status) {
      case DeviceSessionStatus.connected:
        return '已连接';
      case DeviceSessionStatus.connecting:
        return '连接中';
      case DeviceSessionStatus.disconnecting:
        return '断开中';
      case DeviceSessionStatus.disconnected:
        return '已断开';
      case DeviceSessionStatus.error:
        return '异常';
      case DeviceSessionStatus.idle:
        return '空闲';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _color.withValues(alpha: 0.16),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Text(_label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
    );
  }
}

class _MissingDeviceView extends StatelessWidget {
  const _MissingDeviceView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AmbientBackground(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.device_unknown, size: 64, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('未指定设备', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('请从扫描页面选择目标设备。', style: textTheme.bodyMedium?.copyWith(color: Colors.white54)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

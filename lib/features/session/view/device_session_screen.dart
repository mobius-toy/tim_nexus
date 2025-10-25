import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim/tim.dart';

import '../../../core/services/tim_gateway.dart';
import '../../../core/models/waveform.dart';
import '../../../shared/widgets/ambient_background.dart';
import '../../qr_scanner/view/qr_scanner_fullscreen_modal.dart';
import '../../waveform_preview/view/waveform_preview_widget.dart';
import '../controller/device_session_controller.dart';
import '../../../core/utils/color_adapter.dart';

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
                _QRScannerCard(controller: controller),
                const SizedBox(height: 16),
                _WaveformPreviewCard(controller: controller),
                const SizedBox(height: 16),
              ],
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
      decoration: BoxDecoration(color: Colors.white.withAlphaCompat(0.06), borderRadius: BorderRadius.circular(16)),
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
        color: _color.withAlphaCompat(0.16),
        border: Border.all(color: _color.withAlphaCompat(0.5)),
      ),
      child: Text(_label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
    );
  }
}

class _QRScannerCard extends StatefulWidget {
  const _QRScannerCard({required this.controller});

  final DeviceSessionController controller;

  @override
  State<_QRScannerCard> createState() => _QRScannerCardState();
}

class _QRScannerCardState extends State<_QRScannerCard> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isConnected = widget.controller.status == DeviceSessionStatus.connected;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('二维码扫描', style: textTheme.titleLarge),
                Text(
                  isConnected ? '扫描波形数据' : '连接后可用',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isConnected) ...[
              // 二维码扫描按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    final result = await navigator.push(
                      MaterialPageRoute(
                        builder: (context) => QRScannerFullScreenModal(),
                      ),
                    );

                    if (result != null && result is WaveformData && mounted) {
                      widget.controller.importWaveform(result);
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('已导入波形数据: ${result.segments.length} 个波形段'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('扫描二维码导入波形数据'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.cyan.withAlphaCompat(0.2),
                    foregroundColor: Colors.cyan,
                  ),
                ),
              ),
            ] else ...[
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlphaCompat(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlphaCompat(0.2)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_outlined,
                        size: 48,
                        color: Colors.white.withAlphaCompat(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '请先连接设备',
                        style: textTheme.bodyLarge?.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WaveformPreviewCard extends StatelessWidget {
  const _WaveformPreviewCard({required this.controller});

  final DeviceSessionController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isConnected = controller.status == DeviceSessionStatus.connected;
    final waveform = controller.currentWaveform;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('波形预览', style: textTheme.titleLarge),
                if (waveform != null)
                  Text(
                    '${waveform.segments.length} 个波形段',
                    style: textTheme.bodySmall?.copyWith(color: Colors.white54),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (waveform != null) ...[
              // 波形预览区域
              WaveformPreviewWidget(
                segments: waveform.segments,
                totalDuration: waveform.totalDuration,
                height: 200,
                onIntensityChanged: (intensity) {
                  // 实时更新马达强度（仅在播放时）
                  if (controller.waveformPlaybackState == PlaybackState.playing) {
                    controller.playMotor(intensity);
                  }
                },
              ),
              const SizedBox(height: 16),
              // 播放控制按钮
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: isConnected && controller.waveformPlaybackState != PlaybackState.playing
                        ? () => controller.playWaveform()
                        : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('播放'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: controller.waveformPlaybackState == PlaybackState.playing
                        ? () => controller.pauseWaveformPlayback()
                        : null,
                    icon: const Icon(Icons.pause),
                    label: const Text('暂停'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: controller.waveformPlaybackState != PlaybackState.idle
                        ? () => controller.stopWaveformPlayback()
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('停止'),
                  ),
                  const Spacer(),
                  Text(
                    '${(waveform.totalDuration / 1000).toStringAsFixed(1)}s',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ] else ...[
              // 空状态提示
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlphaCompat(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlphaCompat(0.2)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.waves,
                        size: 48,
                        color: Colors.white.withAlphaCompat(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '请先扫描二维码导入波形数据',
                        style: textTheme.bodyLarge?.copyWith(color: Colors.white54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '请使用上方的扫描按钮导入波形数据',
                        style: textTheme.bodyMedium?.copyWith(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
            Icon(Icons.device_unknown, size: 64, color: Colors.white.withAlphaCompat(0.5)),
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

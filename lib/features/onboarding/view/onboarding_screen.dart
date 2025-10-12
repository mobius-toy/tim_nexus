import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/permissions/permission_coordinator.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/widgets/ambient_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PermissionCoordinator>().loadCurrentStatuses();
    });
  }

  Future<void> _handleGetStarted() async {
    setState(() => _requesting = true);
    final coordinator = context.read<PermissionCoordinator>();
    final granted = await coordinator.ensureCorePermissions();
    if (!mounted) return;
    setState(() => _requesting = false);
    if (granted) {
      Navigator.of(context).pushReplacementNamed(AppRouter.scannerRoute);
    } else {
      _showPermissionSheet();
    }
  }

  void _showPermissionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final statuses = context.watch<PermissionCoordinator>().statuses;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '需要权限协助',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                '请在系统设置中允许以下权限，以便 TIM Nexus 正常工作。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...statuses.entries.map(
                (entry) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _iconFor(entry.key),
                    color: _colorFor(entry.value),
                  ),
                  title: Text(_labelFor(entry.key)),
                  subtitle: Text(_statusLabel(entry.value)),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: openAppSettings,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('稍后再说'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statuses = context.watch<PermissionCoordinator>().statuses;
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TIM Nexus', style: textTheme.displayMedium),
                const SizedBox(height: 12),
                Text(
                  '连接设备、雕刻波形、实时观测数据 —— 一站式的 TIM 集成体验。',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                _FeatureTile(
                  icon: Icons.bluetooth_searching,
                  title: '即时扫描',
                  description: '捕捉附近的 TIM 设备，展示信号强度、电量与固件版本。',
                ),
                _FeatureTile(
                  icon: Icons.waves,
                  title: '波形工作台',
                  description: '拖拽节点生成 PWM 曲线，实时推送至设备，打造专属震动体验。',
                ),
                _FeatureTile(
                  icon: Icons.insights,
                  title: '实时遥测',
                  description: '电池、RSSI、指令日志全量可视化，一目了然。',
                ),
                const Spacer(),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('权限状态', style: textTheme.titleLarge),
                        const SizedBox(height: 12),
                        ...statuses.entries.map(
                          (entry) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_labelFor(entry.key)),
                              Text(
                                _statusLabel(entry.value),
                                style: textTheme.labelLarge?.copyWith(
                                  color: _colorFor(entry.value),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _requesting ? null : _handleGetStarted,
                    child: _requesting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('启动体验'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _labelFor(AppPermission permission) {
    switch (permission) {
      case AppPermission.bluetooth:
        return '蓝牙权限';
      case AppPermission.location:
        return '位置权限';
      case AppPermission.notifications:
        return '通知权限';
    }
  }

  IconData _iconFor(AppPermission permission) {
    switch (permission) {
      case AppPermission.bluetooth:
        return Icons.bluetooth;
      case AppPermission.location:
        return Icons.my_location;
      case AppPermission.notifications:
        return Icons.notifications_active;
    }
  }

  Color _colorFor(PermissionStatus status) {
    if (status == PermissionStatus.granted || status == PermissionStatus.limited) {
      return const Color(0xFF00F5C3);
    }
    if (status == PermissionStatus.permanentlyDenied) {
      return Colors.amberAccent;
    }
    return Colors.redAccent;
  }

  String _statusLabel(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '已开启';
      case PermissionStatus.limited:
        return '有限';
      case PermissionStatus.denied:
        return '待授权';
      case PermissionStatus.restricted:
        return '受限制';
      case PermissionStatus.permanentlyDenied:
        return '已拒绝';
      case PermissionStatus.provisional:
        return '临时';
    }
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0x3300F5C3), Color(0x5500F5C3)],
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

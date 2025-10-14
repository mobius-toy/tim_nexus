import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum AppPermission { bluetooth, location, notifications }

class PermissionCoordinator extends ChangeNotifier {
  PermissionCoordinator() {
    _statusMap[AppPermission.bluetooth] = PermissionStatus.denied;
  }

  final Map<AppPermission, PermissionStatus> _statusMap = {AppPermission.bluetooth: PermissionStatus.denied};

  Map<AppPermission, PermissionStatus> get statuses => Map.unmodifiable(_statusMap);

  bool get _skipNativePermissionFlow => Platform.isMacOS || Platform.isIOS;

  // 检查Android版本是否支持新的蓝牙权限 (API 31+)
  Future<bool> _isAndroid12OrHigher() async {
    if (!Platform.isAndroid) return false;
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 31; // Android 12 (API 31)
    } catch (e) {
      // 如果获取失败，默认使用旧权限
      return false;
    }
  }

  bool get allCriticalGranted => _isGranted(AppPermission.bluetooth);

  bool _isGranted(AppPermission permission) {
    final status = _statusMap[permission];
    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }

  Future<void> loadCurrentStatuses() async {
    if (_skipNativePermissionFlow) {
      _statusMap[AppPermission.bluetooth] = PermissionStatus.granted;
      notifyListeners();
      return;
    }

    _statusMap[AppPermission.bluetooth] = await _queryStatus(AppPermission.bluetooth);
    notifyListeners();
  }

  Future<bool> ensureCorePermissions() async {
    if (_skipNativePermissionFlow) {
      _statusMap[AppPermission.bluetooth] = PermissionStatus.granted;
      notifyListeners();
      return true;
    }

    await loadCurrentStatuses();
    if (!_isGranted(AppPermission.bluetooth)) {
      final status = await request(AppPermission.bluetooth);
      return status == PermissionStatus.granted || status == PermissionStatus.limited;
    }
    return true;
  }

  Future<PermissionStatus> request(AppPermission permission) async {
    if (_skipNativePermissionFlow) {
      _statusMap[AppPermission.bluetooth] = PermissionStatus.granted;
      notifyListeners();
      return PermissionStatus.granted;
    }

    PermissionStatus worst = PermissionStatus.granted;
    for (final handlerPermission in await _resolve(permission)) {
      final status = await handlerPermission.request();
      if (status.isPermanentlyDenied) {
        worst = PermissionStatus.permanentlyDenied;
        break;
      }
      if (status.isDenied) {
        worst = PermissionStatus.denied;
      } else if (status.isLimited) {
        worst = PermissionStatus.limited;
      } else if (status.isGranted && worst != PermissionStatus.denied && worst != PermissionStatus.limited) {
        worst = PermissionStatus.granted;
      }
    }
    _statusMap[permission] = worst;
    notifyListeners();
    return worst;
  }

  Future<PermissionStatus> _queryStatus(AppPermission permission) async {
    PermissionStatus worst = PermissionStatus.granted;
    for (final handlerPermission in await _resolve(permission)) {
      final status = await handlerPermission.status;
      if (status.isPermanentlyDenied) {
        return PermissionStatus.permanentlyDenied;
      }
      if (status.isDenied && worst != PermissionStatus.limited) {
        worst = PermissionStatus.denied;
      } else if (status.isLimited) {
        worst = PermissionStatus.limited;
      }
    }
    return worst;
  }

  Future<List<Permission>> _resolve(AppPermission permission) async {
    switch (permission) {
      case AppPermission.bluetooth:
        if (Platform.isAndroid) {
          final isAndroid12OrHigher = await _isAndroid12OrHigher();
          if (isAndroid12OrHigher) {
            // Android 12+ (API 31+) 使用新的蓝牙权限
            return const [Permission.bluetoothScan, Permission.bluetoothConnect];
          } else {
            // Android 11 及以下需要位置权限来扫描蓝牙设备
            return [Permission.bluetooth, Permission.locationWhenInUse];
          }
        } else if (Platform.isIOS) {
          return const [Permission.bluetooth];
        }
        return const [Permission.bluetooth];
      case AppPermission.location:
        if (Platform.isAndroid) {
          return const [Permission.locationWhenInUse];
        }
        return const [Permission.locationWhenInUse];
      case AppPermission.notifications:
        if (Platform.isIOS) {
          return const [Permission.notification];
        }
        return const [Permission.notification];
    }
  }
}

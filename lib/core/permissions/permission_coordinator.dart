import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppPermission { bluetooth, location, notifications }

class PermissionCoordinator extends ChangeNotifier {
  final Map<AppPermission, PermissionStatus> _statusMap = {
    AppPermission.bluetooth: PermissionStatus.denied,
    AppPermission.location: PermissionStatus.denied,
    AppPermission.notifications: PermissionStatus.denied,
  };

  Map<AppPermission, PermissionStatus> get statuses => Map.unmodifiable(_statusMap);

  bool get allCriticalGranted =>
      _isGranted(AppPermission.bluetooth) && _isGranted(AppPermission.location);

  bool _isGranted(AppPermission permission) {
    final status = _statusMap[permission];
    return status == PermissionStatus.granted || status == PermissionStatus.limited;
  }

  Future<void> loadCurrentStatuses() async {
    for (final permission in AppPermission.values) {
      _statusMap[permission] = await _queryStatus(permission);
    }
    notifyListeners();
  }

  Future<bool> ensureCorePermissions() async {
    await loadCurrentStatuses();
    bool grantedAll = true;
    for (final permission in AppPermission.values) {
      if (!_isGranted(permission)) {
        final status = await request(permission);
        grantedAll &= status == PermissionStatus.granted || status == PermissionStatus.limited;
      }
    }
    return grantedAll;
  }

  Future<PermissionStatus> request(AppPermission permission) async {
    PermissionStatus worst = PermissionStatus.granted;
    for (final handlerPermission in _resolve(permission)) {
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
    for (final handlerPermission in _resolve(permission)) {
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

  List<Permission> _resolve(AppPermission permission) {
    switch (permission) {
      case AppPermission.bluetooth:
        if (Platform.isAndroid) {
          return const [
            Permission.bluetoothScan,
            Permission.bluetoothConnect,
            Permission.bluetoothAdvertise,
          ];
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

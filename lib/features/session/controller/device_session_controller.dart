import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tim/tim.dart';

import '../../../core/services/tim_gateway.dart';

enum DeviceSessionStatus {
  idle,
  connecting,
  connected,
  disconnecting,
  disconnected,
  error,
}

class DeviceSessionController extends ChangeNotifier {
  DeviceSessionController({
    required TimGateway gateway,
    required this.deviceId,
  }) : _gateway = gateway;

  final TimGateway _gateway;
  final String deviceId;

  DeviceSessionStatus _status = DeviceSessionStatus.idle;
  DeviceSessionStatus get status => _status;

  TimDevice? _device;
  TimDevice? get device => _device;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _batteryLevel;
  int? get batteryLevel => _batteryLevel;

  int? _rssi;
  int? get rssi => _rssi;

  TimDisconnectReason? _lastDisconnectReason;
  TimDisconnectReason? get lastDisconnectReason => _lastDisconnectReason;

  double _motorIntensity = 0;
  double get motorIntensity => _motorIntensity;

  final List<String> _logs = <String>[];
  List<String> get logs => List.unmodifiable(_logs);

  StreamSubscription<bool>? _connectionSub;
  StreamSubscription<int>? _batterySub;
  StreamSubscription<int>? _rssiSub;
  StreamSubscription<String>? _logSub;

  bool _disposed = false;

  Future<void> initialize() async {
    _status = DeviceSessionStatus.connecting;
    notifyListeners();

    try {
      await _gateway.ensureInitialized();
      _device = _gateway.getDevice(deviceId);
      _attachStreams();
      await _device!.connect();
      _status = DeviceSessionStatus.connected;
      _errorMessage = null;
      _updateDeviceSnapshot();
    } catch (e) {
      _status = DeviceSessionStatus.error;
      _errorMessage = '$e';
      notifyListeners();
    }
  }

  Future<void> reconnect() async {
    if (_device == null) {
      await initialize();
      return;
    }
    _status = DeviceSessionStatus.connecting;
    _errorMessage = null;
    notifyListeners();
    try {
      await _device!.connect();
      _status = DeviceSessionStatus.connected;
      _updateDeviceSnapshot();
    } catch (e) {
      _status = DeviceSessionStatus.error;
      _errorMessage = '$e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    if (_device == null) return;
    _status = DeviceSessionStatus.disconnecting;
    notifyListeners();
    try {
      await _device!.disconnect();
      _status = DeviceSessionStatus.disconnected;
      _lastDisconnectReason = _device!.disconnectReason;
    } catch (e) {
      _status = DeviceSessionStatus.error;
      _errorMessage = '$e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> playMotor(double intensity) async {
    if (_device == null || !_device!.isConnected) return;

    final pwmValue = (255 * intensity).clamp(0, 255).toInt();
    _motorIntensity = intensity;
    notifyListeners();

    try {
      await _device!.writeMotor([pwmValue]);
    } catch (e) {
      _errorMessage = '马达写入失败: $e';
      notifyListeners();
    }
  }

  Future<void> stopMotor() async {
    if (_device == null || !_device!.isConnected) return;
    try {
      await _device!.writeMotorStop();
      _motorIntensity = 0;
    } catch (e) {
      _errorMessage = '马达停止失败: $e';
    } finally {
      notifyListeners();
    }
  }

  void _attachStreams() {
    final device = _device;
    if (device == null) return;

    _connectionSub?.cancel();
    _connectionSub = device.connection.listen((connected) {
      if (_disposed) return;
      _status = connected ? DeviceSessionStatus.connected : DeviceSessionStatus.disconnected;
      if (!connected) {
        _lastDisconnectReason = device.disconnectReason;
      }
      notifyListeners();
    });

    _batterySub?.cancel();
    _batterySub = device.battery.listen((value) {
      if (_disposed) return;
      _batteryLevel = value;
      notifyListeners();
    });

    _rssiSub?.cancel();
    _rssiSub = device.rssi.listen((value) {
      if (_disposed) return;
      _rssi = value;
      notifyListeners();
    });

    _logSub?.cancel();
    _logSub = _gateway.logs.listen((event) {
      if (_disposed) return;
      if (event.contains(deviceId)) {
        _logs.insert(0, '${DateTime.now().toIso8601String()}  $event');
        if (_logs.length > 100) {
          _logs.removeRange(100, _logs.length);
        }
        notifyListeners();
      }
    });
  }

  void _updateDeviceSnapshot() {
    final device = _device;
    if (device == null) return;
    _batteryLevel = device.batteryValue;
    _rssi = device.rssiValue;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _connectionSub?.cancel();
    _batterySub?.cancel();
    _rssiSub?.cancel();
    _logSub?.cancel();
    super.dispose();
  }
}

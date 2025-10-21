import 'dart:async';

import 'package:tim/tim.dart';

class TimGateway {
  TimGateway();

  final Tim _tim = Tim.instance;
  final TimService _service = TimService.instance;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  TimState get currentState => _service.currState;

  Stream<TimState> get state => _service.state;
  Stream<String> get logs => _service.logger;

  // 当前连接的设备（统一命名为 currDevice）
  TimDevice? _currDevice;
  TimDevice? get currDevice => _currDevice;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _tim.initialize();
    _initialized = true;
  }

  Future<List<TimDevice>> scanDevices({
    Duration timeout = const Duration(seconds: 12),
    List<String> withNames = const [],
    OnScanCallback? onFound,
  }) async {
    await ensureInitialized();
    return _tim.startScan(
      timeout: timeout,
      withNames: withNames,
      onFoundDevices: onFound,
    );
  }

  Future<void> stopScan() async {
    await ensureInitialized();
    await _tim.stopScan();
  }

  TimDevice getDevice(String remoteId) {
    return _service.retrieveDevice(remoteId);
  }

  // 连接设备
  Future<TimDevice> connectToDevice(String deviceId) async {
    await ensureInitialized();
    final device = getDevice(deviceId);
    await device.connect();
    _currDevice = device;
    return _currDevice!;
  }

  // 断开连接
  Future<void> disconnect() async {
    await ensureInitialized();
    if (_currDevice != null) {
      await _currDevice!.disconnect();
      _currDevice = null;
    }
  }

  // 发送波形数据
  Future<void> sendWaveform(List<int> waveform) async {
    await ensureInitialized();
    if (_currDevice != null && _currDevice!.isConnected) {
      await _currDevice!.writeMotor(waveform);
    }
  }

  // 播放波形
  Future<void> playWaveform() async {
    await ensureInitialized();
    if (_currDevice != null && _currDevice!.isConnected) {
      // 这里需要实现播放逻辑
      // 暂时使用 writeMotor 方法
    }
  }

  // 停止播放
  Future<void> stopPlayback() async {
    await ensureInitialized();
    if (_currDevice != null && _currDevice!.isConnected) {
      await _currDevice!.writeMotorStop();
    }
  }
}

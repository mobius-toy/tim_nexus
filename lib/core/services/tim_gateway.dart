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
}

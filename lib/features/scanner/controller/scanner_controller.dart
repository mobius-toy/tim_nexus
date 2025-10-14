import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tim/tim.dart';

import '../../../core/services/tim_gateway.dart';

class ScannerController extends ChangeNotifier {
  ScannerController(this._gateway) {
    _stateSubscription = _gateway.state.listen((event) {
      _state = event;
      notifyListeners();
    });
  }

  final TimGateway _gateway;

  TimState _state = TimState.unknown;
  TimState get state => _state;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  String? _error;
  String? get error => _error;

  final List<TimDevice> _devices = [];
  List<TimDevice> get devices => List.unmodifiable(_devices);

  StreamSubscription<TimState>? _stateSubscription;

  Future<void> initialize() async {
    await _gateway.ensureInitialized();
    _state = _gateway.currentState;
    notifyListeners();
  }

  Future<void> refreshLastState() async {
    _state = _gateway.currentState;
    notifyListeners();
  }

  Future<void> startScan() async {
    if (_isScanning) return;
    _error = null;
    if (_state != TimState.on) {
      _error = '蓝牙未就绪，当前状态: $_state';
      notifyListeners();
      return;
    }
    _isScanning = true;
    notifyListeners();

    try {
      await _gateway.scanDevices(
        timeout: const Duration(seconds: 12),
        withNames: const ['GOSH', 'MOBIUS'],
        onFound: (devices) {
          _devices
            ..clear()
            ..addAll(devices);
          notifyListeners();
          return false;
        },
      );
    } catch (e) {
      _error = '$e';
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;
    await _gateway.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(stopScan());
    _stateSubscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/models/waveform.dart';

class QRScannerController extends ChangeNotifier {
  QRScannerController();

  MobileScannerController? _controller;
  MobileScannerController? get controller => _controller;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  String? _lastScannedData;
  String? get lastScannedData => _lastScannedData;

  WaveformData? _scannedWaveform;
  WaveformData? get scannedWaveform => _scannedWaveform;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<BarcodeCapture>? _scanSubscription;

  // 添加扫描成功回调
  Function(WaveformData)? onScanSuccess;

  // 添加标志防止重复触发
  bool _hasTriggeredCallback = false;

  void setController(MobileScannerController controller) {
    _controller = controller;
    notifyListeners();
  }

  void startScanning() {
    if (_controller == null) return;

    _isScanning = true;
    _errorMessage = null;
    notifyListeners();

    _scanSubscription?.cancel();
    _scanSubscription = _controller!.barcodes.listen(
      onQRCodeScanned,
      onError: _onScanError,
    );
  }

  void stopScanning() {
    _isScanning = false;
    _scanSubscription?.cancel();
    notifyListeners();
  }

  void onQRCodeScanned(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final data = barcodes.first.rawValue;
    if (data == null || data.isEmpty) return;

    _lastScannedData = data;

    // 检查是否以 TRD: 开头
    if (!data.startsWith('TRD:')) {
      _errorMessage = '不是有效的波形数据二维码';
      _scannedWaveform = null;
      notifyListeners();
      return;
    }

    try {
      // 提取压缩数据（去掉 TRD: 前缀）
      final compressedData = data.substring(4);

      // 尝试解析为压缩的波形数据
      _scannedWaveform = WaveformData.fromCompressedData(compressedData);
      _errorMessage = null;

      // 扫描成功后自动触发回调（只触发一次）
      if (onScanSuccess != null && !_hasTriggeredCallback) {
        _hasTriggeredCallback = true;
        onScanSuccess!(_scannedWaveform!);
      }
    } catch (e) {
      _errorMessage = '无法解析波形数据: $e';
      _scannedWaveform = null;
    }

    notifyListeners();
  }

  void _onScanError(dynamic error) {
    _errorMessage = '扫描错误: $error';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _lastScannedData = null;
    _scannedWaveform = null;
    _errorMessage = null;
    _hasTriggeredCallback = false; // 重置回调标志
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}

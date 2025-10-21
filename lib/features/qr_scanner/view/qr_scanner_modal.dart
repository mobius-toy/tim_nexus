import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controller/qr_scanner_controller.dart';
import '../../../core/models/waveform.dart';

class QRScannerModal extends StatefulWidget {
  const QRScannerModal({
    super.key,
    this.onWaveformScanned,
  });

  final Function(WaveformData)? onWaveformScanned;

  @override
  State<QRScannerModal> createState() => _QRScannerModalState();
}

class _QRScannerModalState extends State<QRScannerModal> {
  MobileScannerController? _scannerController;
  late QRScannerController _qrController;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      _initializeScanner();
    } else {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _initializeScanner();
      } else {
        setState(() {
          _hasPermission = false;
          _isCheckingPermission = false;
        });
      }
    }
  }

  void _initializeScanner() {
    setState(() {
      _hasPermission = true;
      _isCheckingPermission = false;
    });
    _scannerController = MobileScannerController();
    _qrController = QRScannerController();
    _qrController.setController(_scannerController!);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.cyan),
                SizedBox(height: 16),
                Text(
                  '正在检查相机权限...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  '相机权限被拒绝',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '需要相机权限才能扫描二维码\n请在设置中允许相机权限',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => openAppSettings(),
                      icon: const Icon(Icons.settings),
                      label: const Text('打开设置'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: const Text('关闭'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _qrController,
      child: Consumer<QRScannerController>(
        builder: (context, scannerController, child) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // 标题栏
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                '扫描波形数据',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 扫描器区域
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      bottom: 120,
                      child: Stack(
                        children: [
                          // Mobile Scanner
                          MobileScanner(
                            controller: _scannerController!,
                            onDetect: (capture) {
                              if (scannerController.isScanning) {
                                scannerController.onQRCodeScanned(capture);
                              }
                            },
                          ),

                          // 扫描框
                          if (scannerController.isScanning)
                            Center(
                              child: Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.cyan, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    // 四个角的装饰
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Colors.cyan, width: 4),
                                            left: BorderSide(color: Colors.cyan, width: 4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            top: BorderSide(color: Colors.cyan, width: 4),
                                            right: BorderSide(color: Colors.cyan, width: 4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.cyan, width: 4),
                                            left: BorderSide(color: Colors.cyan, width: 4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: Colors.cyan, width: 4),
                                            right: BorderSide(color: Colors.cyan, width: 4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // 扫描状态指示器
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: scannerController.isScanning
                                    ? Colors.green.withValues(alpha: 0.8)
                                    : Colors.red.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    scannerController.isScanning
                                        ? Icons.qr_code_scanner
                                        : Icons.qr_code_scanner_outlined,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    scannerController.isScanning ? '扫描中' : '已停止',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 错误信息
                          if (scannerController.errorMessage != null)
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        scannerController.errorMessage!,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => scannerController.clearError(),
                                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // 扫描成功信息
                          if (scannerController.scannedWaveform != null)
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '波形数据扫描成功',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${scannerController.scannedWaveform!.segments.length} 个波形段，总时长 ${(scannerController.scannedWaveform!.totalDuration / 1000).toStringAsFixed(1)}s',
                                            style: const TextStyle(color: Colors.white, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (widget.onWaveformScanned != null) {
                                          widget.onWaveformScanned!(scannerController.scannedWaveform!);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.download, color: Colors.white, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // 底部控制栏
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 播放/停止按钮
                            FloatingActionButton(
                              onPressed: scannerController.isScanning
                                  ? () => scannerController.stopScanning()
                                  : () => scannerController.startScanning(),
                              backgroundColor: scannerController.isScanning
                                  ? Colors.red.withValues(alpha: 0.8)
                                  : Colors.green.withValues(alpha: 0.8),
                              child: Icon(
                                scannerController.isScanning ? Icons.stop : Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),

                            // 重置按钮
                            FloatingActionButton(
                              onPressed: () => scannerController.reset(),
                              backgroundColor: Colors.blue.withValues(alpha: 0.8),
                              child: const Icon(Icons.refresh, color: Colors.white),
                            ),

                            // 关闭按钮
                            FloatingActionButton(
                              onPressed: () => Navigator.of(context).pop(),
                              backgroundColor: Colors.grey.withValues(alpha: 0.8),
                              child: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _qrController.dispose();
    super.dispose();
  }
}

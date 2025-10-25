import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controller/qr_scanner_controller.dart';
import '../../../core/models/waveform.dart';
import '../../../core/utils/color_adapter.dart';

class QRScannerWidget extends StatefulWidget {
  const QRScannerWidget({
    super.key,
    this.onWaveformScanned,
    this.height = 300,
  });

  final Function(WaveformData)? onWaveformScanned;
  final double height;

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QRScannerController(),
      child: Consumer<QRScannerController>(
        builder: (context, scannerController, child) {
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlphaCompat(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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

                  // 扫描状态指示器
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scannerController.isScanning
                            ? Colors.green.withAlphaCompat(0.8)
                            : Colors.red.withAlphaCompat(0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            scannerController.isScanning ? Icons.qr_code_scanner : Icons.qr_code_scanner_outlined,
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

                  // 扫描框
                  if (scannerController.isScanning)
                    Positioned(
                      top: widget.height / 2 - 100,
                      left: widget.height / 2 - 100,
                      child: Container(
                        width: 200,
                        height: 200,
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
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.cyan, width: 3),
                                    left: BorderSide(color: Colors.cyan, width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Colors.cyan, width: 3),
                                    right: BorderSide(color: Colors.cyan, width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.cyan, width: 3),
                                    left: BorderSide(color: Colors.cyan, width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.cyan, width: 3),
                                    right: BorderSide(color: Colors.cyan, width: 3),
                                  ),
                                ),
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
                          color: Colors.red.withAlphaCompat(0.9),
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
                          color: Colors.green.withAlphaCompat(0.9),
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
                              },
                              icon: const Icon(Icons.download, color: Colors.white, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 控制按钮
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          onPressed: scannerController.isScanning
                              ? () => scannerController.stopScanning()
                              : () {
                                  scannerController.setController(_scannerController!);
                                  scannerController.startScanning();
                                },
                          backgroundColor: scannerController.isScanning
                              ? Colors.red.withAlphaCompat(0.8)
                              : Colors.green.withAlphaCompat(0.8),
                          child: Icon(
                            scannerController.isScanning ? Icons.stop : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          onPressed: () => scannerController.reset(),
                          backgroundColor: Colors.blue.withAlphaCompat(0.8),
                          child: const Icon(Icons.refresh, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
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
    super.dispose();
  }
}

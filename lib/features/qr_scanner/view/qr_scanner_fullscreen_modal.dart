import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controller/qr_scanner_controller.dart';
import '../../../core/models/waveform.dart';

class QRScannerFullScreenModal extends StatefulWidget {
  const QRScannerFullScreenModal({
    super.key,
    this.onWaveformScanned,
  });

  final Function(WaveformData)? onWaveformScanned;

  @override
  State<QRScannerFullScreenModal> createState() => _QRScannerFullScreenModalState();
}

class _QRScannerFullScreenModalState extends State<QRScannerFullScreenModal> {
  MobileScannerController? _scannerController;
  late QRScannerController _qrController;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        await _initializeScanner();
      } else {
        final result = await Permission.camera.request();
        if (result.isGranted) {
          await _initializeScanner();
        } else {
          setState(() {
            _hasPermission = false;
            _isCheckingPermission = false;
          });
        }
      }
    } catch (e) {
      print('Permission check error: $e');
      setState(() {
        _hasPermission = false;
        _isCheckingPermission = false;
      });
    }
  }

  Future<void> _initializeScanner() async {
    try {
      setState(() {
        _hasPermission = true;
        _isCheckingPermission = false;
      });

      // 创建扫描器控制器
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      // 创建二维码控制器
      _qrController = QRScannerController();
      _qrController.setController(_scannerController!);

      // 设置扫描成功回调
      _qrController.onScanSuccess = (waveform) {
        // 使用 SchedulerBinding 确保在下一帧执行导航
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop(waveform);
          }
        });
      };

      // 等待扫描器初始化
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isInitialized = true;
      });

      // 自动开始扫描
      _qrController.startScanning();
    } catch (e) {
      print('Scanner initialization error: $e');
      setState(() {
        _hasPermission = false;
        _isCheckingPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isCheckingPermission) {
      return _buildPermissionChecking();
    }

    if (!_hasPermission) {
      return _buildPermissionDenied();
    }

    if (!_isInitialized) {
      return _buildInitializing();
    }

    return _buildScanner();
  }

  Widget _buildPermissionChecking() {
    return const Center(
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
    );
  }

  Widget _buildPermissionDenied() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          const Text(
            '相机权限被拒绝',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '需要相机权限才能扫描二维码\n请在设置中允许相机权限',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                label: const Text('关闭'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitializing() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.cyan),
          SizedBox(height: 16),
          Text(
            '正在初始化相机...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return ChangeNotifierProvider.value(
      value: _qrController,
      child: Consumer<QRScannerController>(
        builder: (context, scannerController, child) {
          return Stack(
            children: [
              // 全屏扫描器
              Positioned.fill(
                child: MobileScanner(
                  controller: _scannerController!,
                  onDetect: (capture) {
                    if (scannerController.isScanning) {
                      scannerController.onQRCodeScanned(capture);
                    }
                  },
                ),
              ),

              // 顶部控制栏
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '扫描波形数据',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 扫描框
              Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyan, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // 四个角的装饰
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.cyan, width: 6),
                              left: BorderSide(color: Colors.cyan, width: 6),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.cyan, width: 6),
                              right: BorderSide(color: Colors.cyan, width: 6),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.cyan, width: 6),
                              left: BorderSide(color: Colors.cyan, width: 6),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.cyan, width: 6),
                              right: BorderSide(color: Colors.cyan, width: 6),
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
                top: 100,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '扫描中',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
                  bottom: 200,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            scannerController.errorMessage!,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        IconButton(
                          onPressed: () => scannerController.clearError(),
                          icon: const Icon(Icons.close, color: Colors.white, size: 20),
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
                  bottom: 200,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '波形数据扫描成功',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${scannerController.scannedWaveform!.segments.length} 个波形段，总时长 ${(scannerController.scannedWaveform!.totalDuration / 1000).toStringAsFixed(1)}s',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
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
                          icon: const Icon(Icons.download, color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),

              // 底部关闭按钮
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
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

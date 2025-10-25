import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/waveform_preview_controller.dart';
import '../../../core/models/waveform.dart';
import '../../../core/utils/color_adapter.dart';

class WaveformPreviewWidget extends StatefulWidget {
  const WaveformPreviewWidget({
    super.key,
    required this.segments,
    required this.totalDuration,
    this.height = 200,
    this.showControls = false,
    this.onIntensityChanged,
  });

  final List<WaveSegment> segments;
  final int totalDuration;
  final double height;
  final bool showControls;
  final Function(double)? onIntensityChanged;

  @override
  State<WaveformPreviewWidget> createState() => _WaveformPreviewWidgetState();
}

class _WaveformPreviewWidgetState extends State<WaveformPreviewWidget> {
  late WaveformPreviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WaveformPreviewController(
      segments: widget.segments,
      totalDuration: widget.totalDuration,
    );

    // 监听强度变化
    _controller.addListener(_onIntensityChanged);
  }

  void _onIntensityChanged() {
    if (widget.onIntensityChanged != null) {
      widget.onIntensityChanged!(_controller.getCurrentIntensity());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onIntensityChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<WaveformPreviewController>(
        builder: (context, controller, child) {
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlphaCompat(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  // 波形预览画布
                  Expanded(
                    child: CustomPaint(
                      painter: WaveformPainter(
                        segments: widget.segments,
                        totalDuration: widget.totalDuration,
                        currentPosition: controller.currentPosition,
                        isPlaying: controller.isPlaying,
                      ),
                      size: Size.infinite,
                    ),
                  ),

                  // 控制按钮
                  if (widget.showControls) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlphaCompat(0.3),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          // 播放/暂停按钮
                          IconButton(
                            onPressed: controller.isPlaying ? () => controller.pause() : () => controller.play(),
                            icon: Icon(
                              controller.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),

                          // 停止按钮
                          IconButton(
                            onPressed: controller.isIdle ? null : () => controller.stop(),
                            icon: const Icon(Icons.stop, color: Colors.white),
                          ),

                          const SizedBox(width: 8),

                          // 进度条
                          Expanded(
                            child: Slider(
                              value: controller.currentPosition,
                              onChanged: (value) => controller.seek(value),
                              activeColor: Colors.cyan,
                              inactiveColor: Colors.white.withAlphaCompat(0.3),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 时间显示
                          Text(
                            '${controller.formatDuration((widget.totalDuration * controller.currentPosition).round())} / ${controller.formatDuration(widget.totalDuration)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  WaveformPainter({
    required this.segments,
    required this.totalDuration,
    required this.currentPosition,
    required this.isPlaying,
  });

  final List<WaveSegment> segments;
  final int totalDuration;
  final double currentPosition;
  final bool isPlaying;

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final padding = 20.0;

    // 绘制背景网格
    _drawGrid(canvas, size, padding);

    // 绘制波形
    _drawWaveform(canvas, size, padding);

    // 绘制播放进度
    _drawPlaybackProgress(canvas, size, padding);
  }

  void _drawGrid(Canvas canvas, Size size, double padding) {
    final paint = Paint()
      ..color = Colors.white.withAlphaCompat(0.1)
      ..strokeWidth = 0.5;

    // 水平网格线
    for (int i = 0; i <= 5; i++) {
      final y = padding + (size.height - padding * 2) * i / 5;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        paint,
      );
    }

    // 垂直网格线
    for (int i = 0; i <= 10; i++) {
      final x = padding + (size.width - padding * 2) * i / 10;
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, size.height - padding),
        paint,
      );
    }
  }

  void _drawWaveform(Canvas canvas, Size size, double padding) {
    final drawWidth = size.width - padding * 2;
    final drawHeight = size.height - padding * 2;

    // 绘制波形填充区域
    final fillPaint = Paint()
      ..color = Colors.cyan.withAlphaCompat(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(padding, size.height - padding);

    int accumulatedTime = 0;
    for (final segment in segments) {
      final segmentStartX = padding + (drawWidth * accumulatedTime) / totalDuration;
      final segmentEndX = padding + (drawWidth * (accumulatedTime + segment.duration)) / totalDuration;
      final segmentWidth = segmentEndX - segmentStartX;

      // 生成该段的采样点
      final sampleCount = math.max(2, (segmentWidth * 2).round());
      for (int i = 0; i < sampleCount; i++) {
        final progress = i / (sampleCount - 1);
        final transformedProgress = transformWaveShape(progress, segment.shape);
        final intensity =
            segment.startIntensity + (segment.endIntensity - segment.startIntensity) * transformedProgress;

        final x = segmentStartX + segmentWidth * progress;
        final y = size.height - padding - drawHeight * intensity;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      accumulatedTime += segment.duration;
    }

    path.lineTo(size.width - padding, size.height - padding);
    path.close();
    canvas.drawPath(path, fillPaint);

    // 绘制波形线
    final linePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    accumulatedTime = 0;
    bool isFirstPoint = true;

    for (final segment in segments) {
      final segmentStartX = padding + (drawWidth * accumulatedTime) / totalDuration;
      final segmentEndX = padding + (drawWidth * (accumulatedTime + segment.duration)) / totalDuration;
      final segmentWidth = segmentEndX - segmentStartX;

      // 生成该段的采样点
      final sampleCount = math.max(2, (segmentWidth * 2).round());
      for (int i = 0; i < sampleCount; i++) {
        final progress = i / (sampleCount - 1);
        final transformedProgress = transformWaveShape(progress, segment.shape);
        final intensity =
            segment.startIntensity + (segment.endIntensity - segment.startIntensity) * transformedProgress;

        final x = segmentStartX + segmentWidth * progress;
        final y = size.height - padding - drawHeight * intensity;

        if (isFirstPoint) {
          linePath.moveTo(x, y);
          isFirstPoint = false;
        } else {
          linePath.lineTo(x, y);
        }
      }

      accumulatedTime += segment.duration;
    }

    canvas.drawPath(linePath, linePaint);
  }

  void _drawPlaybackProgress(Canvas canvas, Size size, double padding) {
    final drawWidth = size.width - padding * 2;
    final progressX = padding + drawWidth * currentPosition;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    // 绘制进度线
    canvas.drawLine(
      Offset(progressX, padding),
      Offset(progressX, size.height - padding),
      paint,
    );

    // 绘制进度点
    final progressPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(progressX, size.height - padding),
      4,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.currentPosition != currentPosition ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.segments != segments;
  }
}

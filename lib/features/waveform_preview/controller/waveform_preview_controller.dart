import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/models/waveform.dart';

class WaveformPreviewController extends ChangeNotifier {
  WaveformPreviewController({
    required this.segments,
    required this.totalDuration,
  });

  final List<WaveSegment> segments;
  final int totalDuration;

  PlaybackState _playbackState = PlaybackState.idle;
  PlaybackState get playbackState => _playbackState;

  double _currentPosition = 0.0; // 0-1 的进度
  double get currentPosition => _currentPosition;

  Timer? _playbackTimer;
  int _playbackStartTime = 0;
  int _pausedPosition = 0;

  bool get isPlaying => _playbackState == PlaybackState.playing;
  bool get isPaused => _playbackState == PlaybackState.paused;
  bool get isIdle => _playbackState == PlaybackState.idle;

  // 播放控制
  void play() {
    if (_playbackState == PlaybackState.playing) return;

    _playbackState = PlaybackState.playing;
    _playbackStartTime = DateTime.now().millisecondsSinceEpoch - _pausedPosition;

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - _playbackStartTime;

      if (elapsed >= totalDuration) {
        stop();
        return;
      }

      _currentPosition = elapsed / totalDuration;
      notifyListeners();
    });

    notifyListeners();
  }

  void pause() {
    if (_playbackState != PlaybackState.playing) return;

    _playbackState = PlaybackState.paused;
    _pausedPosition = DateTime.now().millisecondsSinceEpoch - _playbackStartTime;
    _playbackTimer?.cancel();
    notifyListeners();
  }

  void stop() {
    _playbackState = PlaybackState.idle;
    _currentPosition = 0.0;
    _pausedPosition = 0;
    _playbackTimer?.cancel();
    notifyListeners();
  }

  void seek(double position) {
    _currentPosition = position.clamp(0.0, 1.0);
    _pausedPosition = (totalDuration * _currentPosition).round();
    notifyListeners();
  }

  // 获取当前播放位置的波形强度
  double getCurrentIntensity() {
    if (segments.isEmpty) return 0.0;

    final currentTimeMs = (totalDuration * _currentPosition).round();
    int accumulatedTime = 0;

    for (final segment in segments) {
      if (currentTimeMs <= accumulatedTime + segment.duration) {
        final segmentProgress = (currentTimeMs - accumulatedTime) / segment.duration;
        final transformedProgress = transformWaveShape(segmentProgress, segment.shape);
        return segment.startIntensity + (segment.endIntensity - segment.startIntensity) * transformedProgress;
      }
      accumulatedTime += segment.duration;
    }

    return segments.last.endIntensity;
  }

  // 获取指定时间位置的波形强度
  double getIntensityAtTime(double timeMs) {
    if (segments.isEmpty) return 0.0;

    int accumulatedTime = 0;
    for (final segment in segments) {
      if (timeMs <= accumulatedTime + segment.duration) {
        final segmentProgress = (timeMs - accumulatedTime) / segment.duration;
        final transformedProgress = transformWaveShape(segmentProgress, segment.shape);
        return segment.startIntensity + (segment.endIntensity - segment.startIntensity) * transformedProgress;
      }
      accumulatedTime += segment.duration;
    }

    return segments.last.endIntensity;
  }

  // 格式化时间
  String formatDuration(int milliseconds) {
    final seconds = milliseconds / 1000;
    if (seconds < 1) {
      return '${milliseconds}ms';
    } else if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)}s';
    } else {
      final minutes = (seconds / 60).floor();
      final remainingSeconds = seconds % 60;
      return '${minutes}m ${remainingSeconds.toStringAsFixed(1)}s';
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}

// 导入 dart:convert 和 dart:math
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

// 波形形状枚举
enum WaveShape {
  linear('linear', '线性'),
  easeIn('easeIn', '缓入'),
  easeOut('easeOut', '缓出'),
  hold('hold', '保持'),
  sine('sine', '正弦');

  const WaveShape(this.value, this.label);
  final String value;
  final String label;
}

// 波形段模型
class WaveSegment {
  const WaveSegment({
    required this.id,
    required this.startIntensity,
    required this.endIntensity,
    required this.duration,
    required this.shape,
  });

  final int id;
  final double startIntensity; // 0-1 起始强度
  final double endIntensity; // 0-1 结束强度
  final int duration; // 毫秒
  final WaveShape shape;

  WaveSegment copyWith({
    int? id,
    double? startIntensity,
    double? endIntensity,
    int? duration,
    WaveShape? shape,
  }) {
    return WaveSegment(
      id: id ?? this.id,
      startIntensity: startIntensity ?? this.startIntensity,
      endIntensity: endIntensity ?? this.endIntensity,
      duration: duration ?? this.duration,
      shape: shape ?? this.shape,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startIntensity': startIntensity,
      'endIntensity': endIntensity,
      'duration': duration,
      'shape': shape.value,
    };
  }

  factory WaveSegment.fromJson(Map<String, dynamic> json) {
    return WaveSegment(
      id: json['id'] as int,
      startIntensity: (json['startIntensity'] as num).toDouble(),
      endIntensity: (json['endIntensity'] as num).toDouble(),
      duration: json['duration'] as int,
      shape: WaveShape.values.firstWhere(
        (e) => e.value == json['shape'],
        orElse: () => WaveShape.linear,
      ),
    );
  }
}

// 波形数据模型
class WaveformData {
  const WaveformData({
    required this.segments,
    required this.totalDuration,
    this.exportTime,
    this.version = '1.0',
  });

  final List<WaveSegment> segments;
  final int totalDuration; // 毫秒
  final String? exportTime;
  final String version;

  Map<String, dynamic> toJson() {
    return {
      'segments': segments.map((s) => s.toJson()).toList(),
      'totalDuration': totalDuration,
      'exportTime': exportTime ?? DateTime.now().toIso8601String(),
      'version': version,
    };
  }

  factory WaveformData.fromJson(Map<String, dynamic> json) {
    return WaveformData(
      segments: (json['segments'] as List).map((s) => WaveSegment.fromJson(s as Map<String, dynamic>)).toList(),
      totalDuration: json['totalDuration'] as int,
      exportTime: json['exportTime'] as String?,
      version: json['version'] as String? ?? '1.0',
    );
  }

  // 从 JSON 字符串创建
  factory WaveformData.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = const JsonDecoder().convert(jsonString) as Map<String, dynamic>;
    return WaveformData.fromJson(json);
  }

  // 转换为 JSON 字符串
  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  // 从压缩的二进制数据创建波形数据
  factory WaveformData.fromCompressedData(String compressedData) {
    try {
      // 解码base64
      final bytes = base64Decode(compressedData);
      final dataView = ByteData.sublistView(bytes);

      int offset = 0;

      // 读取总时长（4字节）
      final totalDuration = dataView.getUint32(offset);
      offset += 4;

      // 读取波形段
      final segments = <WaveSegment>[];
      int segmentId = 0;

      while (offset < bytes.length) {
        // 读取形状代码（1字节）
        final shapeCode = dataView.getUint8(offset);
        offset += 1;

        // 读取起始强度（1字节）
        final startIntensityRaw = dataView.getUint8(offset);
        offset += 1;

        // 读取结束强度（1字节）
        final endIntensityRaw = dataView.getUint8(offset);
        offset += 1;

        // 读取时长（4字节）
        final duration = dataView.getUint32(offset);
        offset += 4;

        // 转换形状代码
        WaveShape shape;
        switch (shapeCode) {
          case 0:
            shape = WaveShape.linear;
            break;
          case 1:
            shape = WaveShape.easeIn;
            break;
          case 2:
            shape = WaveShape.easeOut;
            break;
          case 3:
            shape = WaveShape.hold;
            break;
          default:
            shape = WaveShape.linear;
        }

        // 转换强度（从0-100转换为0-1）
        final startIntensity = startIntensityRaw / 100.0;
        final endIntensity = endIntensityRaw / 100.0;

        segments.add(
          WaveSegment(
            id: segmentId++,
            startIntensity: startIntensity,
            endIntensity: endIntensity,
            duration: duration,
            shape: shape,
          ),
        );
      }

      return WaveformData(
        segments: segments,
        totalDuration: totalDuration,
        exportTime: DateTime.now().toIso8601String(),
        version: '1.0',
      );
    } catch (e) {
      throw Exception('无法解析压缩的波形数据: $e');
    }
  }
}

// 播放状态枚举
enum PlaybackState {
  idle('idle', '空闲'),
  playing('playing', '播放中'),
  paused('paused', '暂停');

  const PlaybackState(this.value, this.label);
  final String value;
  final String label;
}

// 波形变换函数
double transformWaveShape(double t, WaveShape shape) {
  switch (shape) {
    case WaveShape.linear:
      return t;
    case WaveShape.easeIn:
      return t * t;
    case WaveShape.easeOut:
      return 1 - (1 - t) * (1 - t);
    case WaveShape.hold:
      return 1.0;
    case WaveShape.sine:
      return (1 + math.sin(t * math.pi - math.pi / 2)) / 2;
  }
}

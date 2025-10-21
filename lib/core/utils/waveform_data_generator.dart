import '../../../core/models/waveform.dart';

class WaveformDataGenerator {
  // 生成示例波形数据
  static WaveformData generateSampleWaveform() {
    return WaveformData(
      segments: [
        WaveSegment(
          id: 1,
          startIntensity: 0.0,
          endIntensity: 0.8,
          duration: 2000,
          shape: WaveShape.easeIn,
        ),
        WaveSegment(
          id: 2,
          startIntensity: 0.8,
          endIntensity: 0.8,
          duration: 3000,
          shape: WaveShape.hold,
        ),
        WaveSegment(
          id: 3,
          startIntensity: 0.8,
          endIntensity: 0.0,
          duration: 1500,
          shape: WaveShape.easeOut,
        ),
      ],
      totalDuration: 6500,
      exportTime: DateTime.now().toIso8601String(),
      version: '1.0',
    );
  }

  // 生成脉冲波形
  static WaveformData generatePulseWaveform() {
    return WaveformData(
      segments: [
        WaveSegment(
          id: 1,
          startIntensity: 0.0,
          endIntensity: 1.0,
          duration: 100,
          shape: WaveShape.linear,
        ),
        WaveSegment(
          id: 2,
          startIntensity: 1.0,
          endIntensity: 0.0,
          duration: 100,
          shape: WaveShape.linear,
        ),
        WaveSegment(
          id: 3,
          startIntensity: 0.0,
          endIntensity: 0.0,
          duration: 800,
          shape: WaveShape.hold,
        ),
        WaveSegment(
          id: 4,
          startIntensity: 0.0,
          endIntensity: 1.0,
          duration: 100,
          shape: WaveShape.linear,
        ),
        WaveSegment(
          id: 5,
          startIntensity: 1.0,
          endIntensity: 0.0,
          duration: 100,
          shape: WaveShape.linear,
        ),
        WaveSegment(
          id: 6,
          startIntensity: 0.0,
          endIntensity: 0.0,
          duration: 800,
          shape: WaveShape.hold,
        ),
      ],
      totalDuration: 2000,
      exportTime: DateTime.now().toIso8601String(),
      version: '1.0',
    );
  }

  // 生成波浪波形
  static WaveformData generateWaveWaveform() {
    return WaveformData(
      segments: [
        WaveSegment(
          id: 1,
          startIntensity: 0.0,
          endIntensity: 0.6,
          duration: 1000,
          shape: WaveShape.sine,
        ),
        WaveSegment(
          id: 2,
          startIntensity: 0.6,
          endIntensity: 0.0,
          duration: 1000,
          shape: WaveShape.sine,
        ),
        WaveSegment(
          id: 3,
          startIntensity: 0.0,
          endIntensity: 0.6,
          duration: 1000,
          shape: WaveShape.sine,
        ),
        WaveSegment(
          id: 4,
          startIntensity: 0.6,
          endIntensity: 0.0,
          duration: 1000,
          shape: WaveShape.sine,
        ),
      ],
      totalDuration: 4000,
      exportTime: DateTime.now().toIso8601String(),
      version: '1.0',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tim_nexus/core/utils/color_adapter.dart';

void main() {
  group('ColorAdapter Tests', () {
    test('withAlphaCompat should work with different alpha values', () {
      const baseColor = Colors.red;

      // 测试不同的透明度值
      final color1 = baseColor.withAlphaCompat(0.0);
      final color2 = baseColor.withAlphaCompat(0.5);
      final color3 = baseColor.withAlphaCompat(1.0);

      // 验证透明度是否正确应用
      expect(color1.alpha, equals(0));
      expect(color2.alpha, equals(128)); // 0.5 * 255
      expect(color3.alpha, equals(255));
    });

    test('withAlphaCompat should clamp alpha values', () {
      const baseColor = Colors.blue;

      // 测试超出范围的值
      final colorNegative = baseColor.withAlphaCompat(-0.5);
      final colorOverOne = baseColor.withAlphaCompat(1.5);

      // 验证值被正确限制
      expect(colorNegative.alpha, equals(0));
      expect(colorOverOne.alpha, equals(255));
    });

    test('ColorAdapter static methods should work', () {
      const baseColor = Colors.green;

      // 测试静态方法
      final color1 = ColorAdapter.withAlpha(baseColor, 0.3);
      final color2 = ColorAdapter.withOpacity(baseColor, 0.7);

      expect(color1.alpha, equals(77)); // 0.3 * 255
      expect(color2.alpha, inInclusiveRange(178, 179)); // 0.7 * 255 可能有精度差异
    });

    test('supportsWithOpacity should return true', () {
      expect(ColorAdapter.supportsWithOpacity, isTrue);
    });

    test('supportedMethod should return withOpacity', () {
      expect(ColorAdapter.supportedMethod, equals('withOpacity'));
    });
  });
}

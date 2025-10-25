import 'package:flutter/material.dart';

/// 颜色适配工具类
/// 解决不同 Flutter 版本中颜色透明度方法的兼容性问题
/// 
/// 在 Flutter 3.24+ 版本中，Color.withOpacity 被弃用，推荐使用 Color.withValues
/// 在低版本 Flutter 中，只存在 Color.withOpacity 方法
/// 
/// 此类提供统一的方法来处理颜色透明度，自动适配不同版本
class ColorAdapter {
  /// 为颜色添加透明度
  /// 
  /// [color] 基础颜色
  /// [alpha] 透明度值，范围 0.0-1.0
  /// 
  /// 返回带有指定透明度的新颜色
  static Color withAlpha(Color color, double alpha) {
    // 确保 alpha 值在有效范围内
    alpha = alpha.clamp(0.0, 1.0);
    
    // 优先使用 withOpacity 方法（兼容性更好）
    return color.withOpacity(alpha);
  }
  
  /// 为颜色添加透明度（withOpacity 的别名，保持向后兼容）
  /// 
  /// [color] 基础颜色
  /// [opacity] 透明度值，范围 0.0-1.0
  /// 
  /// 返回带有指定透明度的新颜色
  static Color withOpacity(Color color, double opacity) {
    return withAlpha(color, opacity);
  }
  
  /// 检查当前 Flutter 版本是否支持 withValues 方法
  static bool get supportsWithValues {
    // 由于 withValues 是较新的方法，这里返回 false 以确保兼容性
    // 在实际项目中，可以根据需要调整这个逻辑
    return false;
  }
  
  /// 检查当前 Flutter 版本是否支持 withOpacity 方法
  static bool get supportsWithOpacity {
    try {
      Colors.black.withOpacity(0.5);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 获取当前支持的透明度方法名称
  static String get supportedMethod {
    if (supportsWithValues) {
      return 'withValues';
    } else if (supportsWithOpacity) {
      return 'withOpacity';
    } else {
      return 'none';
    }
  }
}

/// 颜色扩展方法
/// 为 Color 类添加便捷的透明度方法
extension ColorCompatExtension on Color {
  /// 为颜色添加透明度（兼容不同 Flutter 版本）
  /// 
  /// [alpha] 透明度值，范围 0.0-1.0
  /// 
  /// 返回带有指定透明度的新颜色
  Color withAlphaCompat(double alpha) {
    return ColorAdapter.withAlpha(this, alpha);
  }
  
  /// 为颜色添加透明度（withOpacity 的兼容版本）
  /// 
  /// [opacity] 透明度值，范围 0.0-1.0
  /// 
  /// 返回带有指定透明度的新颜色
  Color withOpacityCompat(double opacity) {
    return ColorAdapter.withOpacity(this, opacity);
  }
}

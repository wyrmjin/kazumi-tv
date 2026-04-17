import 'package:flutter/material.dart';

/// TV 适配常量配置
class TVConstants {
  TVConstants._();

  // 焦点动画配置
  static const double focusScale = 1.08;
  static const Duration focusAnimDuration = Duration(milliseconds: 200);
  static const double focusBorderWidth = 3.0;

  // TV 卡片尺寸
  static const double cardWidth = 180.0;
  static const double cardHeight = 240.0;
  static const double cardSpacing = 12.0;

  // 侧边栏配置
  static const double sidebarWidth = 80.0;
  static const double sidebarItemHeight = 64.0;

  // 焦点颜色
  static const Color focusColor = Color(0xFFFB7299);
  static const Color focusShadowColor = Color(0x80FB7299);

  // 字体大小
  static const double titleFontSize = 16.0;
  static const double subtitleFontSize = 14.0;

  // 动画曲线
  static const Curve focusCurve = Curves.easeOutCubic;

  // 图片缓存配置
  static const int maxImageCacheSize = 500;
  static const int maxImageCacheBytes = 200 << 20; // 200MB

  // 交错加载延迟
  static const int staggerLoadDelayMs = 80;
}

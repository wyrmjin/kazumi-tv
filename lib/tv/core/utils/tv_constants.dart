import 'package:flutter/material.dart';

/// TV 适配常量配置
class TVConstants {
  TVConstants._();

  // 品牌色
  static const Color focusColor = Color(0xFFFB7299);
  static const Color focusShadowColor = Color(0x80FB7299);
  static const Color focusGlowColor = Color(0x40FB7299);
  static const Color focusGradientStart = Color(0xFFE8567F);
  static const Color focusGradientEnd = Color(0xFFFB7299);
  static const Color focusColorDim = Color(0x26FB7299); // focusColor @ 15%

  // 背景色系
  static const Color backgroundColor = Color(0xFF0A0A12);
  static const Color surfaceColor = Color(0xFF111118);
  static const Color surfaceVariantColor = Color(0xFF1A1A24);
  static const Color surfaceHighColor = Color(0xFF222230);
  static const Color sidebarGradientStart = Color(0xFF0D0D15);
  static const Color sidebarGradientEnd = Color(0xFF08080E);

  // 边框色
  static const Color borderSubtleColor = Color(0xFF2A2A35);
  static const Color borderFaintColor = Color(0x802A2A35); // borderSubtleColor @ 50%
  static const Color borderMediumColor = Color(0xFF3A3A48);
  static const Color dividerColor = Color(0xFF1E1E2A);

  // 文本色
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFCCCCCC);
  static const Color textTertiaryColor = Color(0xFF888898);
  static const Color textDisabledColor = Color(0xFF555566);

  // 遮罩色
  static const Color overlayMid = Color(0x80000000); // black @ 50%
  static const Color overlayStrong = Color(0xEB000000); // black @ 92%

  // 焦点动画配置
  static const double focusScale = 1.08;
  static const double unfocusedBorderWidth = 1.0;
  static const double focusBorderWidth = 2.5;
  static const double focusElevation = 16.0;
  static const Duration focusAnimDuration = Duration(milliseconds: 200);
  static const Curve focusCurve = Curves.easeOutCubic;
  static const Curve focusBounceCurve = Curves.easeOutBack;

  // TV 卡片尺寸
  static const double cardWidth = 180.0;
  static const double cardHeight = 240.0;
  static const double cardSpacing = 12.0;

  // 侧边栏配置
  static const double sidebarWidth = 80.0;
  static const double sidebarItemHeight = 64.0;

  // 字体大小
  static const double titleFontSize = 16.0;
  static const double subtitleFontSize = 14.0;

  // 图片缓存配置
  static const int maxImageCacheSize = 500;
  static const int maxImageCacheBytes = 200 << 20; // 200MB

  // 交错加载延迟
  static const int staggerLoadDelayMs = 80;
}

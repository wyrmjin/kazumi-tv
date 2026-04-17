import 'package:flutter/material.dart';
import '../utils/tv_constants.dart';

/// TV 卡片视觉效果组件（Stateless）
///
/// 纯视觉效果组件，不管理焦点，只响应 isFocused 参数。
/// 提供缩放、边框、阴影等视觉效果。
class TvCardVisual extends StatelessWidget {
  const TvCardVisual({
    super.key,
    required this.child,
    required this.isFocused,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.focusColor,
  });

  final Widget child;
  final bool isFocused;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? focusColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isFocused ? TVConstants.focusScale : 1.0,
      duration: TVConstants.focusAnimDuration,
      curve: TVConstants.focusCurve,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: isFocused
              ? Border.all(
                  color: focusColor ?? Colors.white,
                  width: TVConstants.focusBorderWidth,
                )
              : null,
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: TVConstants.focusShadowColor,
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: RepaintBoundary(child: child),
        ),
      ),
    );
  }
}

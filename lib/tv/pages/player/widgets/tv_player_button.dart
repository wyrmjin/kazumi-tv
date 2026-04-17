import 'package:flutter/material.dart';
import '../../../core/widgets/tv_button.dart';

/// TV 播放器控制按钮组件
///
/// 提供统一的播放器控制按钮样式，支持禁用状态和焦点动画。
class TVPlayerButton extends StatelessWidget {
  const TVPlayerButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.autofocus = false,
    this.focusNode,
    this.width = 60.0,
    this.height = 60.0,
    this.iconSize = 28.0,
    this.enabled = true,
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
  });

  /// 按钮图标
  final IconData icon;

  /// 点击回调
  final VoidCallback onTap;

  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;

  /// 是否自动获取焦点
  final bool autofocus;

  final FocusNode? focusNode;

  /// 按钮宽度
  final double width;

  /// 按钮高度
  final double height;

  /// 图标大小
  final double iconSize;

  /// 是否启用
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: iconSize,
      color: enabled ? Colors.white : Colors.grey,
    );

    if (!enabled) {
      return SizedBox(
        width: width,
        height: height,
        child: iconWidget,
      );
    }

    return TVButton(
      autofocus: autofocus,
      focusNode: focusNode,
      padding: EdgeInsets.zero,
      borderRadius: 8.0,
      onTap: onTap,
      onUp: onUp,
      onDown: onDown,
      onLeft: onLeft,
      onRight: onRight,
      child: SizedBox(
        width: width,
        height: height,
        child: iconWidget,
      ),
    );
  }
}

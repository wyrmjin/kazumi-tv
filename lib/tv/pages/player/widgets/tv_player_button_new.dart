import 'package:flutter/material.dart';
import 'package:kazumi/tv/core/focus/tv_list_items.dart';

/// TV 播放器按钮（新焦点系统版）
///
/// 使用 TvHorizontalListItem 实现水平焦点导航
class TvPlayerButtonNew extends StatelessWidget {
  const TvPlayerButtonNew({
    super.key,
    required this.icon,
    required this.onTap,
    required this.focusNode,
    this.autofocus = false,
    this.isFirst = false,
    this.isLast = false,
    this.exitLeft,
    this.exitRight,
    this.onMoveUp,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final FocusNode focusNode;
  final bool autofocus;
  final bool isFirst;
  final bool isLast;
  final FocusNode? exitLeft;
  final FocusNode? exitRight;
  final VoidCallback? onMoveUp;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 28,
      color: enabled ? Colors.white : Colors.grey,
    );

    if (!enabled) {
      return SizedBox(
        width: 60,
        height: 60,
        child: iconWidget,
      );
    }

    return TvHorizontalListItem(
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: (_) {},
      isFirst: isFirst,
      isLast: isLast,
      exitLeft: exitLeft,
      exitRight: exitRight,
      onMoveUp: onMoveUp,
      onSelect: () => onTap(),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: iconWidget,
      ),
    );
  }
}
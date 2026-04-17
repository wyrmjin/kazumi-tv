import 'package:flutter/material.dart';
import '../utils/tv_constants.dart';
import '../focus/tv_key_handler_new.dart';
import 'tv_card_visual.dart';

/// TV 卡片基类组件（新设计 - Stateless）
///
/// 采用 Stateless 设计，必须提供外部 focusNode。
/// 焦点状态由外部管理，视觉效果由 TvCardVisual 提供。
class TVCard extends StatelessWidget {
  const TVCard({
    super.key,
    required this.child,
    required this.focusNode,
    this.onFocusChange,
    this.onSelect,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.focusColor,
  });

  final Widget child;
  final FocusNode focusNode;
  final ValueChanged<bool>? onFocusChange;
  final VoidCallback? onSelect;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? focusColor;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          focusNode.requestFocus();
          onSelect?.call();
        },
        child: TvCardVisual(
          isFocused: focusNode.hasFocus,
          width: width,
          height: height,
          borderRadius: borderRadius,
          focusColor: focusColor,
          child: child,
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final selectHandler = onSelect != null
        ? () {
            onSelect!();
            return KeyEventResult.handled;
          }
        : null;
    return TvKeyHandler.handleNavigation(
      event,
      onEnter: selectHandler,
      onSelect: selectHandler,
    );
  }
}

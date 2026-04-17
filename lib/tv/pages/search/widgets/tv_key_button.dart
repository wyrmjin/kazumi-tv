import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TV虚拟键盘按键组件
class TVKeyButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onBack;
  final bool autofocus;
  final FocusNode? focusNode;

  const TVKeyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onMoveLeft,
    this.onMoveRight,
    this.onMoveUp,
    this.onMoveDown,
    this.onBack,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<TVKeyButton> createState() => _TVKeyButtonState();
}

class _TVKeyButtonState extends State<TVKeyButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: _handleKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isFocused ? Colors.white : Colors.white12,
          borderRadius: BorderRadius.circular(8),
          border: _isFocused ? Border.all(color: Colors.white, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            color: _isFocused ? Colors.black : Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select) {
      widget.onTap();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
        widget.onMoveLeft != null) {
      widget.onMoveLeft!();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        widget.onMoveRight != null) {
      widget.onMoveRight!();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        widget.onMoveUp != null) {
      widget.onMoveUp!();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        widget.onMoveDown != null) {
      widget.onMoveDown!();
      return KeyEventResult.handled;
    }

    if ((event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.goBack ||
            event.logicalKey == LogicalKeyboardKey.browserBack) &&
        widget.onBack != null) {
      widget.onBack!();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}

/// TV操作按钮（带背景色）
class TVActionButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onBack;
  final bool autofocus;

  const TVActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.onMoveLeft,
    this.onBack,
    this.autofocus = false,
  });

  @override
  State<TVActionButton> createState() => _TVActionButtonState();
}

class _TVActionButtonState extends State<TVActionButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: _handleKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _isFocused ? Colors.white : widget.color,
          borderRadius: BorderRadius.circular(8),
          border: _isFocused ? Border.all(color: Colors.white, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(
            color: _isFocused ? Colors.black : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select) {
      widget.onTap();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
        widget.onMoveLeft != null) {
      widget.onMoveLeft!();
      return KeyEventResult.handled;
    }

    if ((event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.goBack ||
            event.logicalKey == LogicalKeyboardKey.browserBack) &&
        widget.onBack != null) {
      widget.onBack!();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}

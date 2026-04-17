import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TV 按键处理工具类（Stateless 版本）
///
/// 简化 API，接收 KeyEventResult Function() 回调，
/// 而不是 VoidCallback，便于外部组合处理逻辑。
class TvKeyHandler {
  TvKeyHandler._();

  /// 处理导航按键（仅处理按下事件）
  static KeyEventResult handleNavigation(
    KeyEvent event, {
    KeyEventResult Function()? onUp,
    KeyEventResult Function()? onDown,
    KeyEventResult Function()? onLeft,
    KeyEventResult Function()? onRight,
    KeyEventResult Function()? onEnter,
    KeyEventResult Function()? onSelect,
    KeyEventResult Function()? onBack,
  }) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowUp) {
      return onUp != null ? onUp() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      return onDown != null ? onDown() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      return onLeft != null ? onLeft() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      return onRight != null ? onRight() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.enter) {
      return onEnter != null ? onEnter() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.select) {
      return onSelect != null ? onSelect() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.browserBack) {
      return onBack != null ? onBack() : KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  /// 处理导航按键（支持长按重复）
  static KeyEventResult handleNavigationWithRepeat(
    KeyEvent event, {
    KeyEventResult Function()? onUp,
    KeyEventResult Function()? onDown,
    KeyEventResult Function()? onLeft,
    KeyEventResult Function()? onRight,
    KeyEventResult Function()? onEnter,
    KeyEventResult Function()? onSelect,
    KeyEventResult Function()? onBack,
  }) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowUp) {
      return onUp != null ? onUp() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      return onDown != null ? onDown() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      return onLeft != null ? onLeft() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      return onRight != null ? onRight() : KeyEventResult.ignored;
    }

    // Enter/Select 不处理 KeyRepeatEvent
    if (key == LogicalKeyboardKey.enter) {
      if (event is KeyRepeatEvent) {
        return KeyEventResult.ignored;
      }
      return onEnter != null ? onEnter() : KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.select) {
      if (event is KeyRepeatEvent) {
        return KeyEventResult.ignored;
      }
      return onSelect != null ? onSelect() : KeyEventResult.ignored;
    }

    // Back 不处理 KeyRepeatEvent
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.browserBack) {
      if (event is KeyRepeatEvent) {
        return KeyEventResult.ignored;
      }
      return onBack != null ? onBack() : KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }
}

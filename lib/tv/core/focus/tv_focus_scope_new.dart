import 'package:flutter/material.dart';
import 'focus_pattern.dart';
import 'tv_key_handler_new.dart';

/// 通用的 TV 焦点容器
///
/// 采用 Stateless 设计，减少状态管理开销。
/// 提供双重退出机制（FocusNode + 回调），回调优先级高于 FocusNode。
class TvFocusScope extends StatelessWidget {
  const TvFocusScope({
    super.key,
    required this.pattern,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.onSelect,
    this.exitUp,
    this.exitDown,
    this.exitLeft,
    this.exitRight,
    this.onExitUp,
    this.onExitDown,
    this.onExitLeft,
    this.onExitRight,
    this.isFirst = false,
    this.isLast = false,
    this.enableKeyRepeat = false,
  });

  /// 焦点导航模式
  final FocusPattern pattern;

  /// 子组件
  final Widget child;

  /// 焦点节点
  final FocusNode? focusNode;

  /// 自动获取焦点
  final bool autofocus;

  /// 焦点变化回调
  final ValueChanged<bool>? onFocusChange;

  /// 选择回调（Enter/Select 键触发）
  final VoidCallback? onSelect;

  /// 上方退出焦点节点
  final FocusNode? exitUp;

  /// 下方退出焦点节点
  final FocusNode? exitDown;

  /// 左侧退出焦点节点
  final FocusNode? exitLeft;

  /// 右侧退出焦点节点
  final FocusNode? exitRight;

  /// 上方退出回调
  final VoidCallback? onExitUp;

  /// 下方退出回调
  final VoidCallback? onExitDown;

  /// 左侧退出回调
  final VoidCallback? onExitLeft;

  /// 右侧退出回调
  final VoidCallback? onExitRight;

  /// 是否为首个项目（阻止向上/向左移动）
  final bool isFirst;

  /// 是否为最后项目（阻止向下/向右移动）
  final bool isLast;

  /// 是否启用按键重复
  final bool enableKeyRepeat;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      onKeyEvent: _handleKeyEvent,
      child: child,
    );
  }

  /// 处理按键事件
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final handler = enableKeyRepeat
        ? TvKeyHandler.handleNavigationWithRepeat
        : TvKeyHandler.handleNavigation;

    switch (pattern) {
      case FocusPattern.vertical:
        return handler(
          event,
          onUp: onExitUp != null
              ? _getExitUpHandler()
              : (isFirst ? null : _getExitUpHandler()),
          onDown: onExitDown != null
              ? _getExitDownHandler()
              : (isLast ? null : _getExitDownHandler()),
          onLeft: _getExitLeftHandler(),
          onRight: _getExitRightHandler(),
          onEnter: _getSelectHandler(),
          onSelect: _getSelectHandler(),
        );

      case FocusPattern.horizontal:
        return handler(
          event,
          onUp: _getExitUpHandler(),
          onDown: _getExitDownHandler(),
          onLeft: onExitLeft != null
              ? _getExitLeftHandler()
              : (isFirst ? null : _getExitLeftHandler()),
          onRight: onExitRight != null
              ? _getExitRightHandler()
              : (isLast ? null : _getExitRightHandler()),
          onEnter: _getSelectHandler(),
          onSelect: _getSelectHandler(),
        );

      case FocusPattern.grid:
        return handler(
          event,
          onUp: _getExitUpHandler(),
          onDown: _getExitDownHandler(),
          onLeft: _getExitLeftHandler(),
          onRight: _getExitRightHandler(),
          onEnter: _getSelectHandler(),
          onSelect: _getSelectHandler(),
        );
    }
  }

  /// 获取上方退出处理器
  KeyEventResult Function()? _getExitUpHandler() {
    if (onExitUp != null || exitUp != null) {
      return () {
        _handleExitUp();
        return KeyEventResult.handled;
      };
    }
    return null;
  }

  /// 获取下方退出处理器
  KeyEventResult Function()? _getExitDownHandler() {
    if (onExitDown != null || exitDown != null) {
      return () {
        _handleExitDown();
        return KeyEventResult.handled;
      };
    }
    return null;
  }

  /// 获取左侧退出处理器
  KeyEventResult Function()? _getExitLeftHandler() {
    if (onExitLeft != null || exitLeft != null) {
      return () {
        _handleExitLeft();
        return KeyEventResult.handled;
      };
    }
    return null;
  }

  /// 获取右侧退出处理器
  KeyEventResult Function()? _getExitRightHandler() {
    if (onExitRight != null || exitRight != null) {
      return () {
        _handleExitRight();
        return KeyEventResult.handled;
      };
    }
    return null;
  }

  /// 获取选择处理器
  KeyEventResult Function()? _getSelectHandler() {
    if (onSelect != null) {
      return () {
        onSelect!();
        return KeyEventResult.handled;
      };
    }
    return null;
  }

  /// 处理上方退出
  void _handleExitUp() {
    if (onExitUp != null) {
      onExitUp!();
    } else {
      exitUp?.requestFocus();
    }
  }

  /// 处理下方退出
  void _handleExitDown() {
    if (onExitDown != null) {
      onExitDown!();
    } else {
      exitDown?.requestFocus();
    }
  }

  /// 处理左侧退出
  void _handleExitLeft() {
    if (onExitLeft != null) {
      onExitLeft!();
    } else {
      exitLeft?.requestFocus();
    }
  }

  /// 处理右侧退出
  void _handleExitRight() {
    if (onExitRight != null) {
      onExitRight!();
    } else {
      exitRight?.requestFocus();
    }
  }
}

import 'package:flutter/material.dart';
import 'focus_pattern.dart';
import 'tv_focus_scope_new.dart';
import 'tv_grid_boundary.dart';

/// 简化版的垂直焦点列表项
///
/// 专为设置页面、菜单列表等垂直列表设计
class TvVerticalListItem extends StatelessWidget {
  const TvVerticalListItem({
    super.key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.onSelect,
    this.sidebarFocusNode,
    this.onMoveUp,
    this.onMoveDown,
    this.onMoveLeft,
    this.isFirst = false,
    this.isLast = false,
  });

  final Widget child;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;
  final VoidCallback? onSelect;
  final FocusNode? sidebarFocusNode;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onMoveLeft;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return TvFocusScope(
      pattern: FocusPattern.vertical,
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      onSelect: onSelect,
      exitLeft: sidebarFocusNode,
      onExitLeft: onMoveLeft,
      onExitUp: isFirst ? onMoveUp : null,
      onExitDown: isLast ? onMoveDown : null,
      isFirst: isFirst,
      isLast: isLast,
      child: child,
    );
  }
}

/// 简化版的水平焦点列表项
///
/// 专为底部导航栏、横向轮播等水平列表设计
class TvHorizontalListItem extends StatelessWidget {
  const TvHorizontalListItem({
    super.key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.onSelect,
    this.onMoveUp,
    this.onMoveDown,
    this.exitLeft,
    this.exitRight,
    this.isFirst = false,
    this.isLast = false,
    this.enableKeyRepeat = false,
  });

  final Widget child;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;
  final VoidCallback? onSelect;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final FocusNode? exitLeft;
  final FocusNode? exitRight;
  final bool isFirst;
  final bool isLast;
  final bool enableKeyRepeat;

  @override
  Widget build(BuildContext context) {
    return TvFocusScope(
      pattern: FocusPattern.horizontal,
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      onSelect: onSelect,
      onExitUp: onMoveUp,
      onExitDown: onMoveDown,
      exitLeft: exitLeft,
      exitRight: exitRight,
      isFirst: isFirst,
      isLast: isLast,
      enableKeyRepeat: enableKeyRepeat,
      child: child,
    );
  }
}

/// 网格边界退出方向
enum TvGridExitDirection {
  up,
  down,
  left,
  right,
}

/// 简化版的网格焦点项
///
/// 专为视频网格、图片墙等网格布局设计。
/// 根据网格位置自动判断边界，仅在边界项上触发退出行为。
class TvGridItem extends StatelessWidget {
  const TvGridItem({
    super.key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.onSelect,
    this.index,
    this.crossAxisCount,
    this.totalItems,
    this.exitUp,
    this.exitDown,
    this.exitLeft,
    this.exitRight,
    this.onExitUp,
    this.onExitDown,
    this.onExitLeft,
    this.onExitRight,
    this.enableKeyRepeat = true,
  });

  final Widget child;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;
  final VoidCallback? onSelect;

  final int? index;
  final int? crossAxisCount;
  final int? totalItems;

  final FocusNode? exitUp;
  final FocusNode? exitDown;
  final FocusNode? exitLeft;
  final FocusNode? exitRight;

  final VoidCallback? onExitUp;
  final VoidCallback? onExitDown;
  final VoidCallback? onExitLeft;
  final VoidCallback? onExitRight;

  final bool enableKeyRepeat;

  @override
  Widget build(BuildContext context) {
    final boundary = _calculateBoundary();

    return TvFocusScope(
      pattern: FocusPattern.grid,
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      onSelect: onSelect,
      exitUp: boundary.shouldExitUp() ? exitUp : null,
      onExitUp: boundary.shouldExitUp() ? onExitUp : null,
      exitDown: boundary.shouldExitDown() ? exitDown : null,
      onExitDown: boundary.shouldExitDown() ? onExitDown : null,
      exitLeft: boundary.shouldExitLeft() ? exitLeft : null,
      onExitLeft: boundary.shouldExitLeft() ? onExitLeft : null,
      exitRight: boundary.shouldExitRight() ? exitRight : null,
      onExitRight: boundary.shouldExitRight() ? onExitRight : null,
      enableKeyRepeat: enableKeyRepeat,
      child: child,
    );
  }

  TvGridBoundary _calculateBoundary() {
    if (index == null || crossAxisCount == null || totalItems == null) {
      return TvGridBoundary(index: 0, crossAxisCount: 1, totalItems: 1);
    }
    return TvGridBoundary(
      index: index!,
      crossAxisCount: crossAxisCount!,
      totalItems: totalItems!,
    );
  }
}

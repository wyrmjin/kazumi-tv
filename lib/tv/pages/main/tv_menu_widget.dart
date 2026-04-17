import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/tv_constants.dart';
import '../../core/focus/tv_focus_scope_new.dart';
import '../../core/focus/focus_pattern.dart';

/// TV 侧边菜单组件
class TVMenuWidget extends StatefulWidget {
  const TVMenuWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onMenuItemFocused,
    this.onExitRight,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final ValueChanged<int>? onMenuItemFocused;
  final VoidCallback? onExitRight;

  @override
  State<TVMenuWidget> createState() => TVMenuWidgetState();
}

class TVMenuWidgetState extends State<TVMenuWidget> {
  final List<FocusNode> _itemFocusNodes = [];

  final List<_MenuItemData> _menuItems = [
    _MenuItemData(Icons.home, '推荐'),
    _MenuItemData(Icons.schedule, '时间表'),
    _MenuItemData(Icons.favorite, '追番'),
    _MenuItemData(Icons.search, '搜索'),
    _MenuItemData(Icons.settings, '设置'),
  ];

  @override
  void initState() {
    super.initState();

    // 为每个菜单项创建 FocusNode
    for (var i = 0; i < _menuItems.length; i++) {
      _itemFocusNodes.add(FocusNode(debugLabel: 'menu_item_$i'));
    }

    // 初始焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        requestMenuFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var node in _itemFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void requestMenuFocus() {
    final index = widget.selectedIndex.clamp(0, _itemFocusNodes.length - 1);
    if (_itemFocusNodes.isNotEmpty && index < _itemFocusNodes.length) {
      _itemFocusNodes[index].requestFocus();
    }
  }

  void _handleFocusChange(int index, bool hasFocus) {
    if (hasFocus) {
      widget.onMenuItemFocused?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TVConstants.sidebarWidth + 8,
      color: Colors.black87,
      child: TvFocusScope(
        pattern: FocusPattern.vertical,
        isFirst: true,
        isLast: true,
        onExitRight: widget.onExitRight,
        child: Column(
          children: [
            const SizedBox(height: 48),
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final isFirst = index == 0;
                  final isLast = index == _menuItems.length - 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: _FocusableMenuItem(
                      focusNode: _itemFocusNodes[index],
                      isFirst: isFirst,
                      isLast: isLast,
                      prevNode: index > 0 ? _itemFocusNodes[index - 1] : null,
                      nextNode: index < _itemFocusNodes.length - 1
                          ? _itemFocusNodes[index + 1]
                          : null,
                      onSelect: () => widget.onItemSelected(index),
                      onFocusChange: (hasFocus) =>
                          _handleFocusChange(index, hasFocus),
                      autofocus: index == widget.selectedIndex,
                      child: _MenuCardContent(
                        icon: item.icon,
                        label: item.label,
                        isSelected: widget.selectedIndex == index,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 可聚焦的菜单项（带视觉效果和手动导航）
class _FocusableMenuItem extends StatefulWidget {
  const _FocusableMenuItem({
    required this.focusNode,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
    this.prevNode,
    this.nextNode,
    this.onSelect,
    this.onFocusChange,
    this.autofocus = false,
  });

  final FocusNode focusNode;
  final Widget child;
  final bool isFirst;
  final bool isLast;
  final FocusNode? prevNode;
  final FocusNode? nextNode;
  final VoidCallback? onSelect;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;

  @override
  State<_FocusableMenuItem> createState() => _FocusableMenuItemState();
}

class _FocusableMenuItemState extends State<_FocusableMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: TVConstants.focusAnimDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: TVConstants.focusScale,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: TVConstants.focusCurve,
    ));

    widget.focusNode.addListener(_onFocusChange);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(_FocusableMenuItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _animController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final hasFocus = widget.focusNode.hasFocus;
    setState(() {
      _isFocused = hasFocus;
    });

    if (hasFocus) {
      _animController.forward();
    } else {
      _animController.reverse();
    }

    widget.onFocusChange?.call(hasFocus);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // 上键导航
    if (key == LogicalKeyboardKey.arrowUp) {
      if (widget.isFirst) {
        return KeyEventResult.handled;
      }
      widget.prevNode?.requestFocus();
      return KeyEventResult.handled;
    }

    // 下键导航
    if (key == LogicalKeyboardKey.arrowDown) {
      if (widget.isLast) {
        return KeyEventResult.handled;
      }
      widget.nextNode?.requestFocus();
      return KeyEventResult.handled;
    }

    // 确认键
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
      widget.onSelect?.call();
      return KeyEventResult.handled;
    }

    // 左键 - 让外层处理退出
    if (key == LogicalKeyboardKey.arrowLeft) {
      return KeyEventResult.ignored;
    }

    // 右键 - 让外层处理退出
    if (key == LogicalKeyboardKey.arrowRight) {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          widget.focusNode.requestFocus();
          widget.onSelect?.call();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: _isFocused
                      ? Border.all(
                          color: Colors.white,
                          width: TVConstants.focusBorderWidth,
                        )
                      : null,
                  boxShadow: _isFocused
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
                  borderRadius: BorderRadius.circular(12),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 菜单卡片内容（不含焦点逻辑）
class _MenuCardContent extends StatelessWidget {
  const _MenuCardContent({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: TVConstants.sidebarWidth,
      height: TVConstants.sidebarItemHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? TVConstants.focusColor : Colors.white70,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? TVConstants.focusColor : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;

  _MenuItemData(this.icon, this.label);
}

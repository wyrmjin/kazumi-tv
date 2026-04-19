import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/tv_constants.dart';
import '../../core/focus/tv_focus_scope.dart';
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
    _MenuItemData(Icons.home_rounded, '推荐'),
    _MenuItemData(Icons.schedule_rounded, '时间表'),
    _MenuItemData(Icons.favorite_rounded, '追番'),
    _MenuItemData(Icons.search_rounded, '搜索'),
    _MenuItemData(Icons.settings_rounded, '设置'),
  ];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i < _menuItems.length; i++) {
      _itemFocusNodes.add(FocusNode(debugLabel: 'menu_item_$i'));
    }

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

  bool hasFocus() {
    return _itemFocusNodes.any((node) => node.hasFocus);
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            TVConstants.sidebarGradientStart,
            TVConstants.sidebarGradientEnd,
          ],
        ),
        border: Border(
          right: BorderSide(
            color: TVConstants.borderFaintColor,
            width: 1,
          ),
        ),
      ),
      child: TvFocusScope(
        pattern: FocusPattern.vertical,
        isFirst: true,
        isLast: true,
        onExitRight: widget.onExitRight,
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildLogo(),
            const SizedBox(height: 24),
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

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'K',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: TVConstants.focusColor,
          shadows: [
            Shadow(
              color: TVConstants.focusGlowColor,
              blurRadius: 12,
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

    if (key == LogicalKeyboardKey.arrowUp) {
      if (widget.isFirst) {
        return KeyEventResult.handled;
      }
      widget.prevNode?.requestFocus();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      if (widget.isLast) {
        return KeyEventResult.handled;
      }
      widget.nextNode?.requestFocus();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
      widget.onSelect?.call();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      return KeyEventResult.ignored;
    }

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
                            color: TVConstants.focusGlowColor,
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: TVConstants.focusShadowColor,
                            blurRadius: 8,
                            spreadRadius: 1,
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
    return Container(
      width: TVConstants.sidebarWidth,
      height: TVConstants.sidebarItemHeight,
      decoration: BoxDecoration(
        color: isSelected
            ? TVConstants.surfaceVariantColor
            : Colors.transparent,
      ),
      child: Stack(
        children: [
          if (isSelected)
            Positioned(
              left: 0,
              top: 12,
              bottom: 12,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: TVConstants.focusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isSelected
                        ? TVConstants.focusColor
                        : TVConstants.textTertiaryColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? TVConstants.focusColor
                          : TVConstants.textTertiaryColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;

  _MenuItemData(this.icon, this.label);
}

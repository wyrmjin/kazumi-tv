import 'package:flutter/material.dart';
import 'package:kazumi/tv/core/focus/tv_focus_scope_new.dart';
import 'package:kazumi/tv/core/focus/tv_focus_scope_manager.dart';
import 'package:kazumi/tv/core/focus/tv_list_items.dart';
import 'package:kazumi/tv/core/focus/focus_pattern.dart';
import 'package:kazumi/tv/core/utils/tv_constants.dart';
import 'package:kazumi/tv/core/widgets/tv_card_visual.dart';
import 'player/tv_player_settings_page.dart';
import 'danmaku/tv_danmaku_settings_page.dart';
import 'about/tv_about_page.dart';

class TVSettingsPage extends StatefulWidget {
  const TVSettingsPage({
    super.key,
    this.contentFocusNode,
    this.onExitToMenu,
  });

  final FocusNode? contentFocusNode;
  final VoidCallback? onExitToMenu;

  @override
  State<TVSettingsPage> createState() => _TVSettingsPageState();
}

class _TVSettingsPageState extends State<TVSettingsPage> {
  late final TvFocusScopeManager _focusManager;

  int _selectedIndex = 0;
  final List<FocusNode> _tabItemNodes = [];
  final List<FocusNode> _pageFirstItemNodes = [];

  final List<_SettingsMenuItem> _menuItems = [
    _SettingsMenuItem(Icons.play_circle, '播放设置'),
    _SettingsMenuItem(Icons.comment, '弹幕设置'),
    _SettingsMenuItem(Icons.info, '关于'),
  ];

  @override
  void initState() {
    super.initState();

    _focusManager = TvFocusScopeManager(debugLabel: 'settings_page');
    _focusManager.registerNodes(['tab_bar']);

    for (int i = 0; i < _menuItems.length; i++) {
      if (i == _selectedIndex && widget.contentFocusNode != null) {
        _tabItemNodes.add(widget.contentFocusNode!);
      } else {
        _tabItemNodes.add(FocusNode(debugLabel: 'tab_item_$i'));
      }
      _pageFirstItemNodes.add(FocusNode(debugLabel: 'page_first_$i'));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tabItemNodes.isNotEmpty) {
        _tabItemNodes[_selectedIndex].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusManager.dispose();
    for (int i = 0; i < _tabItemNodes.length; i++) {
      if (i != _selectedIndex || widget.contentFocusNode == null) {
        _tabItemNodes[i].dispose();
      }
    }
    for (final node in _pageFirstItemNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleMenuSelected(int index, bool moveToContent) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    if (moveToContent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pageFirstItemNodes[_selectedIndex].requestFocus();
        }
      });
    }
  }

  void _moveFocusToContent() {
    _pageFirstItemNodes[_selectedIndex].requestFocus();
  }

  void _moveFocusToTab() {
    _tabItemNodes[_selectedIndex].requestFocus();
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TVConstants.surfaceColor,
            TVConstants.backgroundColor,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: TVConstants.dividerColor, width: 1),
        ),
      ),
      child: TvFocusScope(
        pattern: FocusPattern.horizontal,
        focusNode: _focusManager.getNode('tab_bar'),
        autofocus: true,
        onExitDown: _moveFocusToContent,
        onExitLeft: widget.onExitToMenu,
        isFirst: true,
        child: Row(
          children: _menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == _selectedIndex;

            final isLastTab = index == _menuItems.length - 1;
            final nextTabNode = isLastTab ? null : _tabItemNodes[index + 1];
            final prevTabNode = index == 0 ? null : _tabItemNodes[index - 1];

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TvHorizontalListItem(
                focusNode: _tabItemNodes[index],
                autofocus: index == _selectedIndex,
                onFocusChange: (focused) {
                  if (focused && index != _selectedIndex) {
                    _handleMenuSelected(index, false);
                  }
                  setState(() {});
                },
                isFirst: index == 0,
                isLast: isLastTab,
                exitLeft: prevTabNode,
                exitRight: nextTabNode,
                onMoveDown: _moveFocusToContent,
                onSelect: () => _handleMenuSelected(index, true),
                child: TvCardVisual(
                  isFocused: _tabItemNodes[index].hasFocus,
                  borderRadius: 10,
                  focusColor: TVConstants.focusColor,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TVConstants.focusColor
                          : TVConstants.surfaceVariantColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: _tabItemNodes[index].hasFocus || isSelected
                              ? Colors.white
                              : TVConstants.textTertiaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: _tabItemNodes[index].hasFocus || isSelected
                                ? Colors.white
                                : TVConstants.textTertiaryColor,
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        TVPlayerSettingsPage(
          firstItemFocusNode: _pageFirstItemNodes[0],
          onExitUp: _moveFocusToTab,
          onExitLeft: widget.onExitToMenu,
        ),
        TVDanmakuSettingsPage(
          firstItemFocusNode: _pageFirstItemNodes[1],
          onExitUp: _moveFocusToTab,
          onExitLeft: widget.onExitToMenu,
        ),
        TVAboutPage(
          firstItemFocusNode: _pageFirstItemNodes[2],
          onExitUp: _moveFocusToTab,
          onExitLeft: widget.onExitToMenu,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}

class _SettingsMenuItem {
  final IconData icon;
  final String label;

  _SettingsMenuItem(this.icon, this.label);
}

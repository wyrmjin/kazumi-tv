import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kazumi/pages/collect/collect_controller.dart';
import 'package:kazumi/modules/collect/collect_module.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/tv/core/focus/tv_focus_scope_new.dart';
import 'package:kazumi/tv/core/focus/tv_focus_scope_manager.dart';
import 'package:kazumi/tv/core/focus/tv_list_items.dart';
import 'package:kazumi/tv/core/focus/focus_pattern.dart';
import 'package:kazumi/tv/core/utils/tv_constants.dart';
import 'package:kazumi/tv/core/widgets/tv_card_visual.dart';
import 'package:kazumi/tv/widgets/tv_bangumi_card.dart';

class TVCollectPage extends StatefulWidget {
  const TVCollectPage({
    super.key,
    this.contentFocusNode,
    this.onExitToMenu,
  });

  final FocusNode? contentFocusNode;
  final VoidCallback? onExitToMenu;

  @override
  State<TVCollectPage> createState() => _TVCollectPageState();
}

class _TVCollectPageState extends State<TVCollectPage> {
  late final CollectController _controller;
  late final TvFocusScopeManager _focusManager;

  final List<FocusNode> _tabItemNodes = [];
  final Map<int, FocusNode> _gridItemNodes = {};

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['在看', '想看', '搁置', '看过', '抛弃'];

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<CollectController>();
    _controller.loadCollectibles();

    _focusManager = TvFocusScopeManager(debugLabel: 'collect_page');
    _focusManager.registerNodes(['tab_bar', 'grid_area']);
    _focusManager.defineEdges([
      TvFocusEdgeDefinition(
        from: 'tab_bar',
        direction: TvExitDirection.down,
        to: 'grid_area',
      ),
      TvFocusEdgeDefinition(
        from: 'grid_area',
        direction: TvExitDirection.up,
        to: 'tab_bar',
      ),
    ]);

    for (int i = 0; i < _tabs.length; i++) {
      if (i == _selectedTabIndex && widget.contentFocusNode != null) {
        _tabItemNodes.add(widget.contentFocusNode!);
      } else {
        _tabItemNodes.add(FocusNode(debugLabel: 'tab_item_$i'));
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tabItemNodes.isNotEmpty) {
        _tabItemNodes[_selectedTabIndex].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _focusManager.dispose();
    for (int i = 0; i < _tabItemNodes.length; i++) {
      if (i != _selectedTabIndex || widget.contentFocusNode == null) {
        _tabItemNodes[i].dispose();
      }
    }
    for (final node in _gridItemNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleTabSelected(int index, bool moveToGrid) {
    if (_selectedTabIndex == index) return;

    setState(() {
      _selectedTabIndex = index;
    });

    if (moveToGrid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusManager.requestFocus('grid_area');
        }
      });
    }
  }

  void _handleBangumiTap(BangumiItem item) {
    Modular.to.pushNamed('/info', arguments: item);
  }

  FocusNode _getGridItemNode(int index) {
    return _gridItemNodes.putIfAbsent(
      index,
      () => FocusNode(debugLabel: 'grid_item_$index'),
    );
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
        onExitDown: () => _focusManager.requestFocus('grid_area'),
        onExitLeft: widget.onExitToMenu,
        isFirst: true,
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = index == _selectedTabIndex;

            final isLastTab = index == _tabs.length - 1;
            final nextTabNode = isLastTab ? null : _tabItemNodes[index + 1];
            final prevTabNode = index == 0 ? null : _tabItemNodes[index - 1];

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TvHorizontalListItem(
                focusNode: _tabItemNodes[index],
                autofocus: index == _selectedTabIndex,
                onFocusChange: (focused) {
                  if (focused && index != _selectedTabIndex) {
                    _handleTabSelected(index, false);
                  }
                  setState(() {});
                },
                isFirst: index == 0,
                isLast: isLastTab,
                exitLeft: prevTabNode,
                exitRight: nextTabNode,
                onMoveDown: () => _getGridItemNode(0).requestFocus(),
                onSelect: () => _handleTabSelected(index, true),
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
                    child: Text(
                      label,
                      style: TextStyle(
                        color: _tabItemNodes[index].hasFocus || isSelected
                            ? Colors.white
                            : TVConstants.textTertiaryColor,
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
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
    final items = _getItemsForCurrentTab();

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: TVConstants.cardSpacing,
        mainAxisSpacing: TVConstants.cardSpacing,
        childAspectRatio: TVConstants.cardWidth / TVConstants.cardHeight,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridItem(index, item.bangumiItem, items.length);
      },
    );
  }

  Widget _buildGridItem(int index, BangumiItem item, int totalItems) {
    final node = _getGridItemNode(index);

    return TvGridItem(
      focusNode: node,
      index: index,
      crossAxisCount: 5,
      totalItems: totalItems,
      exitUp: _tabItemNodes[_selectedTabIndex],
      onExitLeft: widget.onExitToMenu,
      onSelect: () => _handleBangumiTap(item),
      onFocusChange: (hasFocus) => setState(() {}),
      child: TVBangumiCard(
        bangumiItem: item,
        isFocused: node.hasFocus,
        onSelect: () => _handleBangumiTap(item),
      ),
    );
  }

  List<CollectedBangumi> _getItemsForCurrentTab() {
    final collectibles = _controller.collectibles.toList();

    final type = _selectedTabIndex + 1;
    final filteredItems =
        collectibles.where((item) => item.type == type).toList();

    filteredItems.sort((a, b) =>
        b.time.millisecondsSinceEpoch.compareTo(a.time.millisecondsSinceEpoch));

    return filteredItems;
  }

  Widget _buildEmptyState() {
    final messages = {
      0: '没有在看番剧',
      1: '没有想看番剧',
      2: '没有搁置番剧',
      3: '没有看过番剧',
      4: '没有抛弃番剧',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: TVConstants.textTertiaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            messages[_selectedTabIndex] ?? '暂无内容',
            style: const TextStyle(
              color: TVConstants.textTertiaryColor,
              fontSize: 18,
            ),
          ),
        ],
      ),
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
            child: Observer(builder: (_) => _buildContent()),
          ),
        ],
      ),
    );
  }
}

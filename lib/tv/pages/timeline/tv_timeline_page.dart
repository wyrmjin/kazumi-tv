import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/pages/timeline/timeline_controller.dart';
import 'package:kazumi/tv/core/focus/tv_focus_scope_manager.dart';

import '../../core/focus/focus_pattern.dart';
import '../../core/focus/tv_focus_scope_new.dart';
import '../../core/focus/tv_list_items.dart';
import '../../core/utils/tv_constants.dart';
import '../../core/widgets/tv_card_visual.dart';
import '../../widgets/tv_bangumi_card.dart';

/// TV时间表页面
class TVTimelinePage extends StatefulWidget {
  const TVTimelinePage({
    super.key,
    this.contentFocusNode,
    this.onExitToMenu,
  });

  final FocusNode? contentFocusNode;
  final VoidCallback? onExitToMenu;
  @override
  State<TVTimelinePage> createState() => _TVTimelinePageState();
}

class _TVTimelinePageState extends State<TVTimelinePage> {
  late final TimelineController _controller;
  late final TvFocusScopeManager _focusManager;

  final List<FocusNode> _tabItemNodes = [];
  final Map<int, FocusNode> _gridItemNodes = {};

  int _selectedTabIndex = 0;
  final List<String> _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void initState() {
    super.initState();
    _controller = Modular.get<TimelineController>();

    if (_controller.bangumiCalendar.isEmpty) {
      _controller.init();
    }

    _selectedTabIndex = DateTime.now().weekday - 1;
    _focusManager = TvFocusScopeManager(debugLabel: 'timeline_page');
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

    for (int i = 0; i < _weekdays.length; i++) {
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
          )
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
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
          children: _weekdays.asMap().entries.map((entry) {
            final index = entry.key;
            final isSelected = index == _selectedTabIndex;
            final isTabFocused = _tabItemNodes[index].hasFocus;

            final isLastTab = index == _weekdays.length - 1;
            final nextTabNode = isLastTab ? null : _tabItemNodes[index + 1];
            final prevTabNode = index == 0 ? null : _tabItemNodes[index - 1];

            return Padding(
              padding: const EdgeInsets.only(right: 12),
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
                  isFocused: isTabFocused,
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
                      entry.value,
                      style: TextStyle(
                        color: isTabFocused || isSelected
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
    if (_controller.isLoading && _controller.bangumiCalendar.isEmpty) {
      return _buildLoadingState();
    }
    if (_controller.isTimeOut && _controller.bangumiCalendar.isEmpty) {
      return _buildErrorState();
    }
    if (_controller.bangumiCalendar.isEmpty) {
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
        itemCount: _controller.bangumiCalendar[_selectedTabIndex].length,
        itemBuilder: (context, index) {
          return _buildGridItem(
              index,
              _controller.bangumiCalendar[_selectedTabIndex][index],
              _controller.bangumiCalendar[_selectedTabIndex].length);
        });
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

  FocusNode _getGridItemNode(int index) {
    return _gridItemNodes.putIfAbsent(
      index,
      () => FocusNode(debugLabel: 'grid_item_$index'),
    );
  }

  void _handleBangumiTap(BangumiItem item) {
    Modular.to.pushNamed('/info', arguments: item);
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '正在加载时间表...',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            '加载失败，请检查网络连接',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _controller.getSchedules(),
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        '暂无内容',
        style: TextStyle(color: Colors.white70, fontSize: 18),
      ),
    );
  }
}

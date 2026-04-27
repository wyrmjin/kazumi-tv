import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kazumi/pages/popular/popular_controller.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/utils/constants.dart';
import '../../core/focus/tv_focus_scope.dart';
import '../../core/focus/tv_focus_scope_manager.dart';
import '../../core/focus/focus_pattern.dart';
import '../../core/focus/tv_list_items.dart';
import '../../core/utils/tv_constants.dart';
import '../../core/widgets/tv_card_visual.dart';
import '../../widgets/tv_bangumi_card.dart';

/// TV 推荐页面
class TVPopularPage extends StatefulWidget {
  const TVPopularPage({
    super.key,
    this.contentFocusNode,
    this.onExitToMenu,
  });

  final FocusNode? contentFocusNode;
  final VoidCallback? onExitToMenu;

  @override
  State<TVPopularPage> createState() => _TVPopularPageState();
}

class _TVPopularPageState extends State<TVPopularPage> {
  late final PopularController _controller;
  late final TvFocusScopeManager _focusManager;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  final List<FocusNode> _tabItemNodes = [];
  final Map<int, FocusNode> _gridItemNodes = {};
  final List<GlobalKey> _tabKeys = [];

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['', ...defaultAnimeTags];

  @override
  void initState() {
    super.initState();

    _controller = Modular.get<PopularController>();
    _controller.queryBangumiByTrend(type: 'init');

    _focusManager = TvFocusScopeManager(debugLabel: 'popular_page');
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
      _tabKeys.add(GlobalKey(debugLabel: 'tab_key_$i'));
    }

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tabItemNodes.isNotEmpty) {
        _tabItemNodes[_selectedTabIndex].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabScrollController.dispose();
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_controller.isLoadingMore) {
        if (_controller.currentTag.isEmpty) {
          _controller.queryBangumiByTrend(type: 'add');
        } else {
          _controller.queryBangumiByTag(type: 'add');
        }
      }
    }
  }

  void _handleBangumiTap(BangumiItem item) {
    Modular.to.pushNamed('/info/', arguments: item);
  }

  void _handleTabSelected(int index, bool moveToGrid) {
    if (_selectedTabIndex == index) return;

    _gridItemNodes.forEach((_, node) => node.dispose());
    _gridItemNodes.clear();

    setState(() {
      _selectedTabIndex = index;
    });

    final tag = _tabs[index];

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    if (tag.isEmpty) {
      _controller.setCurrentTag('');
      _controller.clearBangumiList();
      if (_controller.trendList.isEmpty) {
        _controller.queryBangumiByTrend();
      }
    } else {
      _controller.setCurrentTag(tag);
      _controller.queryBangumiByTag(type: 'init');
    }

    _scrollTabToVisible(index);

    if (moveToGrid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusManager.requestFocus('grid_area');
        }
      });
    }
  }

  void _scrollTabToVisible(int index) {
    if (!_tabScrollController.hasClients) return;
    final key = _tabKeys[index];
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void requestInitialFocus() {
    if (mounted && _tabItemNodes.isNotEmpty) {
      _tabItemNodes[_selectedTabIndex].requestFocus();
    }
  }

  FocusNode _getGridItemNode(int index) {
    return _gridItemNodes.putIfAbsent(
      index,
      () => FocusNode(debugLabel: 'grid_item_$index'),
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
        child: SizedBox(
          height: 48,
          child: ListView.custom(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            childrenDelegate: SliverChildListDelegate(
              _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final isSelected = index == _selectedTabIndex;
                final isTabFocused = _tabItemNodes[index].hasFocus;

                final isLastTab = index == _tabs.length - 1;
                final nextTabNode = isLastTab ? null : _tabItemNodes[index + 1];
                final prevTabNode =
                    index == 0 ? null : _tabItemNodes[index - 1];

                return Center(
                  key: _tabKeys[index],
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TvHorizontalListItem(
                      focusNode: _tabItemNodes[index],
                      autofocus: index == _selectedTabIndex,
                      onFocusChange: (focused) {
                        if (focused && index != _selectedTabIndex) {
                          _handleTabSelected(index, false);
                        } else if (focused) {
                          _scrollTabToVisible(index);
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TVConstants.focusColor
                                : TVConstants.surfaceVariantColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entry.value.isEmpty ? '热门番组' : entry.value,
                            style: TextStyle(
                              color: isTabFocused || isSelected
                                  ? Colors.white
                                  : TVConstants.textTertiaryColor,
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final bangumiList = _controller.currentTag.isEmpty
        ? _controller.trendList
        : _controller.bangumiList;

    if (_controller.isLoadingMore && bangumiList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.isTimeOut && bangumiList.isEmpty) {
      return _buildErrorState();
    }

    if (bangumiList.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: TVConstants.cardSpacing,
        mainAxisSpacing: TVConstants.cardSpacing,
        childAspectRatio: TVConstants.cardWidth / TVConstants.cardHeight,
      ),
      itemCount: bangumiList.length,
      itemBuilder: (context, index) {
        return _buildGridItem(index, bangumiList[index], bangumiList.length);
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '加载失败',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_controller.currentTag.isEmpty) {
                _controller.queryBangumiByTrend(type: 'init');
              } else {
                _controller.queryBangumiByTag(type: 'init');
              }
            },
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

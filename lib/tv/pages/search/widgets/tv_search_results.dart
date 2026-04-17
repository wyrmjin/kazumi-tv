import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/tv/widgets/tv_bangumi_card.dart';

/// TV搜索结果网格组件
class TVSearchResults extends StatefulWidget {
  final List<BangumiItem> results;
  final ScrollController scrollController;
  final VoidCallback? onLoadMore;
  final VoidCallback? onBack;
  final VoidCallback? onExitLeft;
  final FocusNode? firstItemFocusNode;

  /// 网格列数
  final int crossAxisCount;

  const TVSearchResults({
    super.key,
    required this.results,
    required this.scrollController,
    this.onLoadMore,
    this.onBack,
    this.onExitLeft,
    this.firstItemFocusNode,
    this.crossAxisCount = 4,
  });

  @override
  State<TVSearchResults> createState() => _TVSearchResultsState();
}

class _TVSearchResultsState extends State<TVSearchResults> {
  final Map<int, FocusNode> _gridItemNodes = {};

  @override
  void didUpdateWidget(TVSearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.results.length < oldWidget.results.length) {
      final toRemove = _gridItemNodes.keys
          .where((k) => k >= widget.results.length)
          .toList();
      for (final key in toRemove) {
        _gridItemNodes[key]!.dispose();
        _gridItemNodes.remove(key);
      }
    }
  }

  @override
  void dispose() {
    for (final node in _gridItemNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _getGridItemNode(int index) {
    return _gridItemNodes.putIfAbsent(
      index,
      () => FocusNode(debugLabel: 'search_grid_item_$index'),
    );
  }

  int? _getFocusedIndex() {
    if (widget.firstItemFocusNode?.hasFocus ?? false) return 0;
    for (final entry in _gridItemNodes.entries) {
      if (entry.value.hasFocus) return entry.key;
    }
    return null;
  }

  KeyEventResult _handleGridKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final focusedIndex = _getFocusedIndex();
      if (focusedIndex != null && focusedIndex % widget.crossAxisCount == 0) {
        widget.onExitLeft?.call();
        return KeyEventResult.handled;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.escape ||
        event.logicalKey == LogicalKeyboardKey.goBack ||
        event.logicalKey == LogicalKeyboardKey.browserBack) {
      widget.onBack?.call();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
      return _buildEmptyState();
    }

    return Focus(
      onKeyEvent: _handleGridKeyEvent,
      child: GridView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 0.65,
        ),
        itemCount: widget.results.length,
        itemBuilder: (context, index) {
          final item = widget.results[index];

          if (index == widget.results.length - 4 && widget.onLoadMore != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onLoadMore?.call();
            });
          }

          return TVBangumiCard(
            bangumiItem: item,
            focusNode: index == 0 ? widget.firstItemFocusNode : _getGridItemNode(index),
            onSelect: () => Modular.to.pushNamed('/info', arguments: item),
            onFocusChange: (_) => setState(() {}),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            '未找到相关番剧',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

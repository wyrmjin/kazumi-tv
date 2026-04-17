import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TV搜索历史列表组件
class TVSearchHistory extends StatelessWidget {
  final List<String> history;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;
  final VoidCallback? onBack;
  final VoidCallback? onExitLeft;
  final FocusNode? firstItemFocusNode;

  const TVSearchHistory({
    super.key,
    required this.history,
    required this.onSelect,
    required this.onClear,
    this.onBack,
    this.onExitLeft,
    this.firstItemFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '搜索历史',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: history.length + 1,
              itemBuilder: (context, index) {
                if (index < history.length) {
                  final item = history[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HistoryItem(
                      text: item,
                      icon: Icons.history,
                      onTap: () => onSelect(item),
                      onBack: onBack,
                      onExitLeft: onExitLeft,
                      autofocus: index == 0,
                      focusNode: index == 0 ? firstItemFocusNode : null,
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: _HistoryItem(
                      text: '清除搜索记录',
                      icon: Icons.delete_outline,
                      onTap: onClear,
                      onBack: onBack,
                      onExitLeft: onExitLeft,
                      autofocus: false,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无搜索历史',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// 搜索历史单项组件
class _HistoryItem extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onBack;
  final VoidCallback? onExitLeft;
  final bool autofocus;
  final FocusNode? focusNode;

  const _HistoryItem({
    required this.text,
    this.icon,
    required this.onTap,
    this.onBack,
    this.onExitLeft,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<_HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      onKeyEvent: (node, event) => _handleKeyEvent(node, event),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isFocused ? Colors.white : Colors.white12,
          borderRadius: BorderRadius.circular(8),
          border: _isFocused ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: _isFocused ? Colors.black87 : Colors.white54,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.text,
                style: TextStyle(
                  color: _isFocused ? Colors.black : Colors.white70,
                  fontSize: 16,
                  fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.select) {
      widget.onTap();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
        widget.onExitLeft != null) {
      widget.onExitLeft!();
      return KeyEventResult.handled;
    }

    if ((event.logicalKey == LogicalKeyboardKey.escape ||
            event.logicalKey == LogicalKeyboardKey.goBack ||
            event.logicalKey == LogicalKeyboardKey.browserBack) &&
        widget.onBack != null) {
      widget.onBack!();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}

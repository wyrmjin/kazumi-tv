import 'package:flutter/material.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/tv/core/focus/tv_list_items.dart';
import 'package:kazumi/tv/core/utils/tv_constants.dart';

class TVPluginCard extends StatefulWidget {
  final Plugin plugin;
  final VoidCallback? onDelete;
  final bool autofocus;

  const TVPluginCard({
    super.key,
    required this.plugin,
    this.onDelete,
    this.autofocus = false,
  });

  @override
  State<TVPluginCard> createState() => _TVPluginCardState();
}

class _TVPluginCardState extends State<TVPluginCard> {
  late final FocusNode _cardFocusNode;
  late final FocusNode _deleteFocusNode;

  @override
  void initState() {
    super.initState();
    _cardFocusNode = FocusNode(debugLabel: 'plugin_card');
    _deleteFocusNode = FocusNode(debugLabel: 'plugin_delete_btn');
  }

  @override
  void dispose() {
    _cardFocusNode.dispose();
    _deleteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TvVerticalListItem(
      focusNode: _cardFocusNode,
      autofocus: widget.autofocus,
      onSelect: () {
        // 插件卡片整体可获得焦点，但无点击操作
        // 删除操作通过卡片内的删除按钮触发
      },
      onFocusChange: (hasFocus) => setState(() {}),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _cardFocusNode.hasFocus
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: _cardFocusNode.hasFocus
              ? Border.all(color: TVConstants.focusColor, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plugin.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TVConstants.focusColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.plugin.version,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.plugin.useNativePlayer
                                  ? Colors.green.withAlpha(50)
                                  : Colors.blue.withAlpha(50),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.plugin.useNativePlayer
                                  ? 'native'
                                  : 'webview',
                              style: TextStyle(
                                color: widget.plugin.useNativePlayer
                                    ? Colors.green
                                    : Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.onDelete != null)
                  TvVerticalListItem(
                    focusNode: _deleteFocusNode,
                    onSelect: widget.onDelete!,
                    onFocusChange: (hasFocus) => setState(() {}),
                    child: TextButton(
                      onPressed: widget.onDelete!,
                      style: TextButton.styleFrom(
                        foregroundColor: _deleteFocusNode.hasFocus
                            ? TVConstants.focusColor
                            : Colors.red,
                      ),
                      child: const Text('删除'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

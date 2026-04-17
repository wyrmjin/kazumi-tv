import 'package:flutter/material.dart';
import 'package:kazumi/tv/core/focus/tv_list_items.dart';

class TVSettingsToggleRow extends StatefulWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool autofocus;
  final bool isFirst;
  final bool isLast;
  final FocusNode? focusNode;
  final FocusNode? sidebarFocusNode;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onMoveLeft;

  const TVSettingsToggleRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.autofocus = false,
    this.isFirst = false,
    this.isLast = false,
    this.focusNode,
    this.sidebarFocusNode,
    this.onMoveUp,
    this.onMoveDown,
    this.onMoveLeft,
  });

  @override
  State<TVSettingsToggleRow> createState() => _TVSettingsToggleRowState();
}

class _TVSettingsToggleRowState extends State<TVSettingsToggleRow> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'settings_toggle_row');
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TvVerticalListItem(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      isFirst: widget.isFirst,
      isLast: widget.isLast,
      sidebarFocusNode: widget.sidebarFocusNode,
      onMoveUp: widget.onMoveUp,
      onMoveDown: widget.onMoveDown,
      onMoveLeft: widget.onMoveLeft,
      onSelect: () => widget.onChanged(!widget.value),
      onFocusChange: (hasFocus) => setState(() {}),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: _focusNode.hasFocus
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: _focusNode.hasFocus
              ? Border.all(color: const Color(0xFFfb7299), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color:
                          _focusNode.hasFocus ? Colors.white : Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Switch(
              value: widget.value,
              onChanged: null,
              activeTrackColor: const Color(0xFFfb7299).withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFfb7299);
                }
                return Colors.grey;
              }),
            ),
          ],
        ),
      ),
    );
  }
}

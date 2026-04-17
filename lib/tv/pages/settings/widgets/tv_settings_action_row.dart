import 'package:flutter/material.dart';
import 'package:kazumi/tv/core/focus/tv_list_items.dart';

class TVSettingsActionRow extends StatefulWidget {
  final String label;
  final String? subtitle;
  final String? value;
  final String buttonLabel;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool isFirst;
  final bool isLast;
  final FocusNode? sidebarFocusNode;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const TVSettingsActionRow({
    super.key,
    required this.label,
    this.subtitle,
    this.value,
    required this.buttonLabel,
    required this.onTap,
    this.autofocus = false,
    this.isFirst = false,
    this.isLast = false,
    this.sidebarFocusNode,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  State<TVSettingsActionRow> createState() => _TVSettingsActionRowState();
}

class _TVSettingsActionRowState extends State<TVSettingsActionRow> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'settings_action_row');
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
      onSelect: widget.onTap ?? () {},
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
                  if (widget.value != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.value!,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _focusNode.hasFocus
                    ? const Color(0xFFfb7299)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.buttonLabel,
                style: TextStyle(
                  color: _focusNode.hasFocus ? Colors.white : Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

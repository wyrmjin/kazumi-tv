import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TVSettingsDropdownRow<T> extends StatelessWidget {
  final String label;
  final String? subtitle;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool autofocus;
  final bool isFirst;
  final bool isLast;
  final FocusNode? focusNode;
  final FocusNode? sidebarFocusNode;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onMoveLeft;

  const TVSettingsDropdownRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.items,
    required this.itemLabel,
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

  void _nextValue() {
    final currentIndex = items.indexOf(value);
    final nextIndex = (currentIndex + 1) % items.length;
    onChanged(items[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowLeft:
            if (onMoveLeft != null) {
              onMoveLeft!();
            } else {
              sidebarFocusNode?.requestFocus();
            }
            return KeyEventResult.handled;
          case LogicalKeyboardKey.arrowUp:
            if (isFirst && onMoveUp != null) {
              onMoveUp!();
              return KeyEventResult.handled;
            }
            return isFirst ? KeyEventResult.handled : KeyEventResult.ignored;
          case LogicalKeyboardKey.arrowDown:
            if (isLast && onMoveDown != null) {
              onMoveDown!();
              return KeyEventResult.handled;
            }
            return isLast ? KeyEventResult.handled : KeyEventResult.ignored;
          case LogicalKeyboardKey.arrowRight:
          case LogicalKeyboardKey.enter:
          case LogicalKeyboardKey.select:
            _nextValue();
            return KeyEventResult.handled;
          default:
            return KeyEventResult.ignored;
        }
      },
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            decoration: BoxDecoration(
              color: isFocused
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isFocused
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
                        label,
                        style: TextStyle(
                          color: isFocused ? Colors.white : Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            subtitle!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFocused
                        ? const Color(0xFFfb7299)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        itemLabel(value),
                        style: TextStyle(
                          color: isFocused ? Colors.white : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: isFocused ? Colors.white : Colors.white54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

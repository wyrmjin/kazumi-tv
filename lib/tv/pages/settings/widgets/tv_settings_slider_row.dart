import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TVSettingsSliderRow extends StatefulWidget {
  final String label;
  final String? subtitle;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String? valueLabel;
  final bool autofocus;
  final bool isFirst;
  final bool isLast;
  final FocusNode? focusNode;
  final FocusNode? sidebarFocusNode;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onMoveLeft;

  const TVSettingsSliderRow({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    this.valueLabel,
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
  State<TVSettingsSliderRow> createState() => _TVSettingsSliderRowState();
}

class _TVSettingsSliderRowState extends State<TVSettingsSliderRow> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  bool _isAdjusting = false;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (_isAdjusting) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          final newValue = (widget.value - 0.1).clamp(widget.min, widget.max);
          widget.onChanged(newValue);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowRight:
          final newValue = (widget.value + 0.1).clamp(widget.min, widget.max);
          widget.onChanged(newValue);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          setState(() => _isAdjusting = false);
          return KeyEventResult.handled;
        default:
          return KeyEventResult.ignored;
      }
    } else {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          if (widget.isFirst && widget.onMoveUp != null) {
            widget.onMoveUp!();
            return KeyEventResult.handled;
          }
          return widget.isFirst
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        case LogicalKeyboardKey.arrowDown:
          if (widget.isLast && widget.onMoveDown != null) {
            widget.onMoveDown!();
            return KeyEventResult.handled;
          }
          return widget.isLast
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        case LogicalKeyboardKey.arrowLeft:
          if (widget.onMoveLeft != null) {
            widget.onMoveLeft!();
          } else {
            widget.sidebarFocusNode?.requestFocus();
          }
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.select:
          setState(() => _isAdjusting = true);
          return KeyEventResult.handled;
        default:
          return KeyEventResult.ignored;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKeyEvent,
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
                      Row(
                        children: [
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: isFocused ? Colors.white : Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (widget.valueLabel != null || _isAdjusting)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isAdjusting
                                    ? const Color(0xFFfb7299)
                                    : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.valueLabel ??
                                    '${widget.value.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: _isAdjusting
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
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
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _isAdjusting
                              ? const Color(0xFFfb7299)
                              : const Color(0xFFfb7299).withValues(alpha: 0.5),
                          inactiveTrackColor:
                              Colors.white.withValues(alpha: 0.1),
                          thumbColor: const Color(0xFFfb7299),
                          overlayColor:
                              const Color(0xFFfb7299).withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: widget.value,
                          min: widget.min,
                          max: widget.max,
                          divisions: widget.divisions,
                          onChanged: widget.onChanged,
                        ),
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

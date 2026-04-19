import 'package:flutter/material.dart';
import '../utils/tv_constants.dart';
import '../focus/tv_key_handler.dart';

/// TV 按钮组件
class TVButton extends StatefulWidget {
  const TVButton({
    super.key,
    required this.child,
    required this.onTap,
    this.onFocus,
    this.onUnfocus,
    this.autofocus = false,
    this.focusNode,
    this.focusColor,
    this.backgroundColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onFocus;
  final VoidCallback? onUnfocus;
  final bool autofocus;
  final FocusNode? focusNode;
  final Color? focusColor;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;

  @override
  State<TVButton> createState() => _TVButtonState();
}

class _TVButtonState extends State<TVButton>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _animController = AnimationController(
      duration: TVConstants.focusAnimDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: TVConstants.focusScale,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: TVConstants.focusCurve,
    ));

    _focusNode.addListener(_onFocusChange);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(TVButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _ownsFocusNode = false;
      } else {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      }
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _animController.forward();
      widget.onFocus?.call();
    } else {
      _animController.reverse();
      widget.onUnfocus?.call();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    return TvKeyHandler.handleNavigation(
      event,
      onUp: widget.onUp != null
          ? () {
              widget.onUp!();
              return KeyEventResult.handled;
            }
          : null,
      onDown: widget.onDown != null
          ? () {
              widget.onDown!();
              return KeyEventResult.handled;
            }
          : null,
      onLeft: widget.onLeft != null
          ? () {
              widget.onLeft!();
              return KeyEventResult.handled;
            }
          : null,
      onRight: widget.onRight != null
          ? () {
              widget.onRight!();
              return KeyEventResult.handled;
            }
          : null,
      onEnter: () {
        widget.onTap();
        return KeyEventResult.handled;
      },
      onSelect: () {
        widget.onTap();
        return KeyEventResult.handled;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusColor = widget.focusColor ?? TVConstants.focusColor;
    final bgColor = widget.backgroundColor ?? Theme.of(context).cardColor;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: _isFocused ? focusColor : bgColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: _isFocused
                      ? Border.all(
                          color: Colors.white,
                          width: TVConstants.focusBorderWidth,
                        )
                      : null,
                ),
                child: child,
              ),
            );
          },
          child: DefaultTextStyle(
            style: TextStyle(
              color: _isFocused ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

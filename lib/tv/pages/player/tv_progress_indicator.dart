import 'package:flutter/material.dart';
import 'widgets/tv_seek_indicator.dart';

/// TV 进度跳转指示器
///
/// 临时显示跳转方向和时长，用于用户进度跳转操作时
class TVProgressIndicator extends StatefulWidget {
  const TVProgressIndicator({
    super.key,
    required this.isVisible,
    required this.direction,
    required this.amount,
  });

  final bool isVisible;
  final String direction; // 'forward' 或 'backward'
  final int amount; // 跳转秒数

  @override
  State<TVProgressIndicator> createState() => _TVProgressIndicatorState();
}

class _TVProgressIndicatorState extends State<TVProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  @override
  void didUpdateWidget(TVProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible && _controller.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: TVSeekIndicator(
          direction: widget.direction,
          amount: widget.amount,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// TV 跳转时长指示器
///
/// 显示进度跳转方向和时长,如 "前进10秒"、"后退20秒"
class TVSeekIndicator extends StatelessWidget {
  const TVSeekIndicator({
    super.key,
    required this.direction,
    required this.amount,
  });

  final String direction; // 'forward' 或 'backward'
  final int amount; // 跳转秒数

  String _getDisplayText() {
    final directionText = direction == 'forward' ? '前进' : '后退';
    return '$directionText${amount}秒';
  }

  IconData _getDisplayIcon() {
    return direction == 'forward' ? Icons.fast_forward : Icons.fast_rewind;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getDisplayIcon(),
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 16),
            Text(
              _getDisplayText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

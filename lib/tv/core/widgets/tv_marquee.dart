import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

/// 条件跑马灯组件
///
/// 自动检测文本是否溢出,仅在溢出时启用滚动
class TVMarquee extends StatelessWidget {
  const TVMarquee({
    super.key,
    required this.text,
    this.style,
    this.maxWidth,
    this.scrollSpeed = 30.0,
    this.blankSpace = 40.0,
  });

  final String text;
  final TextStyle? style;
  final double? maxWidth;
  final double scrollSpeed;
  final double blankSpace;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: effectiveStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(minWidth: 0, maxWidth: double.infinity);

        final availableWidth = maxWidth ?? constraints.maxWidth;
        final textWidth = textPainter.width;

        if (textWidth <= availableWidth) {
          return Text(
            text,
            style: effectiveStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        return SizedBox(
          width: availableWidth,
          height: effectiveStyle.fontSize != null
              ? effectiveStyle.fontSize! * 1.2
              : 20,
          child: Marquee(
            text: text,
            style: effectiveStyle,
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            startPadding: 0,
            velocity: scrollSpeed,
            blankSpace: blankSpace,
            startAfter: const Duration(milliseconds: 800),
            pauseAfterRound: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}

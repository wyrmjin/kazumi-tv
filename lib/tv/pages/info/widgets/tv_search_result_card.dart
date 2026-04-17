import 'package:flutter/material.dart';
import '../../../core/widgets/tv_card_visual.dart';
import '../../../core/widgets/tv_marquee.dart';

/// TV 搜索结果卡片组件
///
/// 用于 TvGridItem 内部时，焦点由 TvGridItem 管理，
/// 因此使用 TvCardVisual（纯视觉）而非 TVCard（带 Focus）。
/// 通过 isFocused 参数驱动视觉状态。
class TVSearchResultCard extends StatelessWidget {
  const TVSearchResultCard({
    super.key,
    required this.title,
    this.isFocused = false,
    this.onSelect,
  });

  final String title;
  final bool isFocused;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: TvCardVisual(
        isFocused: isFocused,
        height: 40,
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TVMarquee(
              text: title,
              style: TextStyle(
                fontSize: 18,
                color: isFocused ? Colors.white : Colors.white70,
              ),
            ),
          ),
          Icon(
            Icons.play_arrow,
            size: 24,
            color: isFocused ? Colors.white : Colors.white70,
          ),
        ],
      ),
    );
  }
}

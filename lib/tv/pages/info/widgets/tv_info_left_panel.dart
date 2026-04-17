import 'package:flutter/material.dart';
import 'package:kazumi/bean/card/network_img_layer.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import '../../../core/widgets/tv_marquee.dart';
import 'tv_collect_button.dart';

/// TV 番剧详情页左侧信息区
class TVInfoLeftPanel extends StatelessWidget {
  final BangumiItem bangumiItem;
  final FocusNode collectFocusNode;
  final VoidCallback? onExitRight;
  final VoidCallback? onExitUp;
  final VoidCallback? onExitDown;

  const TVInfoLeftPanel({
    super.key,
    required this.bangumiItem,
    required this.collectFocusNode,
    this.onExitRight,
    this.onExitUp,
    this.onExitDown,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.4,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverImage(screenWidth, screenHeight),
          const SizedBox(height: 24),
          _buildTitle(),
          const SizedBox(height: 16),
          _buildInfoRow(
              '评分', '${bangumiItem.ratingScore} (${bangumiItem.votes}人评分)'),
          const SizedBox(height: 12),
          _buildInfoRow(
              '排名', bangumiItem.rank > 0 ? '第${bangumiItem.rank}名' : '暂无排名'),
          const SizedBox(height: 12),
          _buildInfoRow('放送日期', bangumiItem.airDate),
          const SizedBox(height: 16),
          TVCollectButton(
            bangumiItem: bangumiItem,
            autofocus: false,
            focusNode: collectFocusNode,
            onUp: onExitUp,
            onDown: onExitDown,
            onRight: onExitRight,
          ),
          const SizedBox(height: 16),
          _buildTags(context),
          const SizedBox(height: 16),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildCoverImage(double screenWidth, double screenHeight) {
    final imageUrl =
        bangumiItem.images['large'] ?? bangumiItem.images['common'] ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: NetworkImgLayer(
        src: imageUrl,
        width: screenWidth * 0.4 - 48,
        height: screenHeight * 0.4,
        type: 'bg',
      ),
    );
  }

  Widget _buildTitle() {
    final title =
        bangumiItem.nameCn.isNotEmpty ? bangumiItem.nameCn : bangumiItem.name;

    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TVMarquee(
        text: title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        maxWidth: double.infinity,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    if (bangumiItem.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标签',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: bangumiItem.tags.take(10).map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag.name,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '简介',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          bangumiItem.summary,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

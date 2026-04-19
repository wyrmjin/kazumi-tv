import 'package:flutter/material.dart';
import 'package:kazumi/bean/card/network_img_layer.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import '../../../core/widgets/tv_marquee.dart';
import '../../../core/utils/tv_constants.dart';
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
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: TVConstants.borderFaintColor,
            width: 1,
          ),
        ),
      ),
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
    final imageWidth = screenWidth * 0.4 - 48;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: NetworkImgLayer(
        src: imageUrl,
        width: imageWidth,
        height: imageWidth * 4 / 3,
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
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: TVConstants.textPrimaryColor,
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
            style: TextStyle(
              fontSize: 14,
              color: TVConstants.textTertiaryColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: TVConstants.textSecondaryColor,
            ),
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
        Text(
          '标签',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TVConstants.textPrimaryColor,
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
                color: TVConstants.surfaceVariantColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag.name,
                style: TextStyle(
                  fontSize: 12,
                  color: TVConstants.textSecondaryColor,
                ),
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
        Text(
          '简介',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: TVConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          bangumiItem.summary,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: TVConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

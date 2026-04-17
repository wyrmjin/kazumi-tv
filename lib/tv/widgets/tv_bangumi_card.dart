import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../modules/bangumi/bangumi_item.dart';
import '../core/widgets/tv_card.dart';
import '../core/widgets/tv_card_visual.dart';
import '../core/widgets/tv_marquee.dart';
import '../core/utils/tv_constants.dart';

/// TV 番剧卡片组件
class TVBangumiCard extends StatelessWidget {
  const TVBangumiCard({
    super.key,
    required this.bangumiItem,
    this.focusNode,
    this.isFocused,
    this.onFocusChange,
    this.onSelect,
    this.width = TVConstants.cardWidth,
    this.height = TVConstants.cardHeight,
  });

  final BangumiItem bangumiItem;
  final FocusNode? focusNode;
  final bool? isFocused;
  final ValueChanged<bool>? onFocusChange;
  final VoidCallback? onSelect;
  final double width;
  final double height;

  String get _coverUrl =>
      bangumiItem.images['large'] ?? bangumiItem.images['common'] ?? '';

  @override
  Widget build(BuildContext context) {
    if (isFocused != null) {
      return GestureDetector(
        onTap: onSelect,
        child: TvCardVisual(
          isFocused: isFocused!,
          width: width,
          height: height,
          child: _buildCardContent(),
        ),
      );
    }

    return TVCard(
      focusNode: focusNode!,
      onFocusChange: onFocusChange,
      onSelect: onSelect,
      width: width,
      height: height,
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCoverImage(),
        _buildGradientOverlay(),
        _buildInfoSection(),
      ],
    );
  }

  Widget _buildCoverImage() {
    return CachedNetworkImage(
      imageUrl: _coverUrl,
      fit: BoxFit.cover,
      memCacheWidth: (width * 2).toInt(),
      memCacheHeight: (height * 2).toInt(),
      placeholder: (context, url) => Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[800],
        child: const Icon(Icons.broken_image, color: Colors.white54),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: height * 0.4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.9),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Positioned(
      left: 8,
      right: 8,
      bottom: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TVMarquee(
            text: bangumiItem.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: TVConstants.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
            maxWidth: width - 16,
          ),
          if (bangumiItem.nameCn.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              bangumiItem.nameCn,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: TVConstants.subtitleFontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

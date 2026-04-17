import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/tv_button.dart';
import 'package:kazumi/pages/video/video_controller.dart';

/// TV 选集菜单
///
/// 右侧滑出菜单，显示剧集列表，支持快速选集
class TVEpisodeMenu extends StatefulWidget {
  const TVEpisodeMenu({
    super.key,
    required this.isOpen,
    required this.videoPageController,
    required this.onEpisodeSelected,
    required this.onClose,
  });

  final bool isOpen;
  final VideoPageController videoPageController;
  final Function(int episode) onEpisodeSelected;
  final VoidCallback onClose;

  @override
  State<TVEpisodeMenu> createState() => _TVEpisodeMenuState();
}

class _TVEpisodeMenuState extends State<TVEpisodeMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final FocusNode _menuFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  @override
  void didUpdateWidget(TVEpisodeMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _controller.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _menuFocusNode.requestFocus();
      });
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _menuFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.goBack ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        widget.onClose();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen && _controller.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final menuWidth = 300.0;

    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Focus(
            focusNode: _menuFocusNode,
            onKeyEvent: _handleKeyEvent,
            child: Container(
              width: menuWidth,
              height: screenHeight,
              color: Colors.black.withOpacity(0.85),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      '选集',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  Expanded(
                    child: _buildEpisodeList(menuWidth),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeList(double menuWidth) {
    final roadList = widget.videoPageController.roadList;
    final currentEpisode = widget.videoPageController.currentEpisode;

    if (roadList.isEmpty) {
      return const Center(
        child: Text(
          '暂无剧集',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final currentRoad = widget.videoPageController.currentRoad;
    if (currentRoad >= roadList.length) {
      return const Center(
        child: Text(
          '线路数据错误',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final episodes = roadList[currentRoad].identifier;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episodeNumber = index + 1;
        final isCurrentEpisode = episodeNumber == currentEpisode;
        final episodeTitle = episodes[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TVButton(
            autofocus: isCurrentEpisode,
            onTap: () {
              widget.onEpisodeSelected(episodeNumber);
            },
            backgroundColor: isCurrentEpisode
                ? Colors.orange.withOpacity(0.3)
                : Colors.transparent,
            focusColor: Colors.orange.withOpacity(0.5),
            borderRadius: 8.0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: menuWidth - 48,
              height: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '第$episodeNumber集 $episodeTitle',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

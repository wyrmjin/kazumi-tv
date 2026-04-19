import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/utils/logger.dart';
import 'tv_player_controls.dart';
import 'tv_episode_menu.dart';
import 'tv_progress_indicator.dart';
import 'package:kazumi/pages/player/player_controller.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/pages/player/player_item_surface.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/tv/core/focus/tv_key_handler.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

/// TV 播放器主页面
///
/// 管理播放器状态、按键事件分发、控制面板和选集菜单显示
class TVPlayerPage extends StatefulWidget {
  const TVPlayerPage({super.key});

  @override
  State<TVPlayerPage> createState() => _TVPlayerPageState();
}

class _TVPlayerPageState extends State<TVPlayerPage> {
  final PlayerController playerController = Modular.get<PlayerController>();
  final VideoPageController videoPageController =
      Modular.get<VideoPageController>();
  final FocusNode _pageFocusNode = FocusNode();
  final FocusNode _controlsFocusNode = FocusNode();
  final _danmuKey = GlobalKey();

  final setting = GStorage.setting;

  late bool _border;
  late double _opacity;
  late double _fontSize;
  late double _danmakuArea;
  late bool _hideTop;
  late bool _hideBottom;
  late bool _hideScroll;
  late bool _massiveMode;
  late double _danmakuDuration;
  late double _danmakuLineHeight;
  late int _danmakuFontWeight;
  late bool _danmakuUseSystemFont;
  late double _danmakuBorderSize;
  late bool _danmakuColor;
  late bool _danmakuBiliBiliSource;
  late bool _danmakuGamerSource;
  late bool _danmakuDanDanSource;

  bool _isControlsVisible = false;
  Timer? _controlsHideTimer;
  bool _isEpisodeMenuOpen = false;
  ReactionDisposer? _completionReaction;

  bool _isSeeking = false;
  String _seekDirection = 'forward';
  Timer? _seekExecuteTimer;
  Timer? _seekAccumulateTimer;
  // Prevents double-pop from both key handler and system back gesture
  bool _isExiting = false;

  static const int _seekStep = 10;

  static const int _seekAccumulateInterval = 300;

  static const int _seekExecuteDelay = 500;

  static const int _controlsHideDelay = 10;

  @override
  void initState() {
    super.initState();
    _pageFocusNode.requestFocus();

    playerController.danmakuOn =
        setting.get(SettingBoxKey.danmakuEnabledByDefault, defaultValue: false);
    _border = setting.get(SettingBoxKey.danmakuBorder, defaultValue: true);
    _opacity = setting.get(SettingBoxKey.danmakuOpacity, defaultValue: 1.0);
    _fontSize = setting.get(SettingBoxKey.danmakuFontSize, defaultValue: 25.0);
    _danmakuArea = setting.get(SettingBoxKey.danmakuArea, defaultValue: 1.0);
    _hideTop = !setting.get(SettingBoxKey.danmakuTop, defaultValue: true);
    _hideBottom =
        !setting.get(SettingBoxKey.danmakuBottom, defaultValue: false);
    _hideScroll = !setting.get(SettingBoxKey.danmakuScroll, defaultValue: true);
    _massiveMode =
        setting.get(SettingBoxKey.danmakuMassive, defaultValue: false);
    _danmakuDuration =
        setting.get(SettingBoxKey.danmakuDuration, defaultValue: 8.0);
    _danmakuLineHeight =
        setting.get(SettingBoxKey.danmakuLineHeight, defaultValue: 1.6);
    _danmakuFontWeight =
        setting.get(SettingBoxKey.danmakuFontWeight, defaultValue: 4);
    _danmakuUseSystemFont =
        setting.get(SettingBoxKey.useSystemFont, defaultValue: false);
    _danmakuBorderSize =
        setting.get(SettingBoxKey.danmakuBorderSize, defaultValue: 1.5);
    _danmakuColor =
        setting.get(SettingBoxKey.danmakuColor, defaultValue: true);
    _danmakuBiliBiliSource =
        setting.get(SettingBoxKey.danmakuBiliBiliSource, defaultValue: true);
    _danmakuGamerSource =
        setting.get(SettingBoxKey.danmakuGamerSource, defaultValue: true);
    _danmakuDanDanSource =
        setting.get(SettingBoxKey.danmakuDanDanSource, defaultValue: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      videoPageController.changeEpisode(
        videoPageController.currentEpisode,
        currentRoad: videoPageController.currentRoad,
        offset: videoPageController.historyOffset,
      );
    });

    _completionReaction = reaction(
      (_) => playerController.completed,
      (completed) {
        if (completed) {
          _autoPlayNextEpisode();
        }
      },
    );
  }

  @override
  void dispose() {
    _completionReaction?.call();
    _completionReaction = null;
    _controlsHideTimer?.cancel();
    _seekExecuteTimer?.cancel();
    _seekAccumulateTimer?.cancel();
    playerController.pause();
    _pageFocusNode.dispose();
    _controlsFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!(event is KeyDownEvent || event is KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }

    final logicalKey = event.logicalKey;

    if (_isEpisodeMenuOpen) {
      return KeyEventResult.ignored;
    }

    if (videoPageController.errorMessage != null) {
      if (logicalKey == LogicalKeyboardKey.select ||
          logicalKey == LogicalKeyboardKey.enter) {
        videoPageController.changeEpisode(
          videoPageController.currentEpisode,
          currentRoad: videoPageController.currentRoad,
          offset: 0,
        );
        return KeyEventResult.handled;
      }
      if (logicalKey == LogicalKeyboardKey.escape ||
          logicalKey == LogicalKeyboardKey.goBack) {
        _exitPlayer();
        return KeyEventResult.handled;
      }
      return KeyEventResult.handled;
    }

    if (_isControlsVisible) {
      if (logicalKey == LogicalKeyboardKey.escape ||
          logicalKey == LogicalKeyboardKey.goBack) {
        _hideControls();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return TvKeyHandler.handleNavigationWithRepeat(
      event,
      onSelect: () {
        _showControls();
        return KeyEventResult.handled;
      },
      onEnter: () {
        _showControls();
        return KeyEventResult.handled;
      },
      onUp: () {
        _showControls();
        return KeyEventResult.handled;
      },
      onDown: () {
        _showControls();
        return KeyEventResult.handled;
      },
      onLeft: () {
        _handleSeek('backward', event is KeyRepeatEvent);
        return KeyEventResult.handled;
      },
      onRight: () {
        _handleSeek('forward', event is KeyRepeatEvent);
        return KeyEventResult.handled;
      },
      onBack: () {
        _exitPlayer();
        return KeyEventResult.handled;
      },
    );
  }

  void _showControls() {
    setState(() {
      _isControlsVisible = true;
    });
    _startControlsHideTimer();
  }

  void _hideControls() {
    _controlsHideTimer?.cancel();
    setState(() {
      _isControlsVisible = false;
    });
  }

  void _startControlsHideTimer() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(
      Duration(seconds: _controlsHideDelay),
      () {
        if (!_isEpisodeMenuOpen) {
          _hideControls();
        }
      },
    );
  }

  void _handleSeek(String direction, bool isRepeat) {
    setState(() {
      _isSeeking = true;
      _seekDirection = direction;
    });

    if (isRepeat && _seekAccumulateTimer == null) {
      _doSeekStep();
      _seekAccumulateTimer = Timer.periodic(
        Duration(milliseconds: _seekAccumulateInterval),
        (_) => _doSeekStep(),
      );
    }

    _scheduleSeekStop();
  }

  void _scheduleSeekStop() {
    _seekExecuteTimer?.cancel();
    _seekExecuteTimer = Timer(
      Duration(milliseconds: _seekExecuteDelay),
      () {
        final wasContinuous = _seekAccumulateTimer != null;
        _seekAccumulateTimer?.cancel();
        _seekAccumulateTimer = null;

        if (!wasContinuous) {
          _doSeekStep();
        }

        setState(() {
          _isSeeking = false;
        });
      },
    );
  }

  void _doSeekStep() {
    final currentPosition = playerController.playerPosition;
    final duration = playerController.playerDuration;
    final offset = Duration(seconds: _seekStep);

    Duration newPosition;
    if (_seekDirection == 'forward') {
      newPosition = currentPosition + offset;
      if (newPosition > duration) {
        newPosition = duration;
        KazumiDialog.showToast(message: '已在结尾');
      }
    } else {
      newPosition = currentPosition - offset;
      if (newPosition < Duration.zero) {
        newPosition = Duration.zero;
        KazumiDialog.showToast(message: '已在开头');
      }
    }

    playerController.seek(newPosition);
  }

  void _onPlayPause() {
    if (playerController.playing) {
      playerController.pause();
    } else {
      playerController.play();
    }
    _startControlsHideTimer();
  }

  void _onChangeEpisode(int offset) {
    if (videoPageController.loading) return;

    final currentEpisode = videoPageController.currentEpisode;
    final roadList = videoPageController.roadList;
    final currentRoad = videoPageController.currentRoad;

    if (!videoPageController.isRoadValid) {
      KazumiDialog.showToast(message: '播放列表加载中，请稍候');
      _startControlsHideTimer();
      return;
    }

    final totalEpisodes = roadList[currentRoad].identifier.length;
    final targetEpisode = currentEpisode + offset;

    if (targetEpisode <= 0) {
      KazumiDialog.showToast(message: '已经是第一集');
      _startControlsHideTimer();
      return;
    }
    if (targetEpisode > totalEpisodes) {
      KazumiDialog.showToast(message: '已经是最新一集');
      _startControlsHideTimer();
      return;
    }

    final identifier = roadList[currentRoad].identifier[targetEpisode - 1];
    KazumiDialog.showToast(message: '正在加载$identifier');
    videoPageController.changeEpisode(targetEpisode, currentRoad: currentRoad);
    _startControlsHideTimer();
  }

  void _onNextEpisode() => _onChangeEpisode(1);

  void _onPreviousEpisode() => _onChangeEpisode(-1);

  void _autoPlayNextEpisode() {
    if (videoPageController.loading) return;

    final roadList = videoPageController.roadList;
    final currentRoad = videoPageController.currentRoad;
    final currentEpisode = videoPageController.currentEpisode;

    if (!videoPageController.isRoadValid) return;

    final totalEpisodes = roadList[currentRoad].identifier.length;
    final nextEpisode = currentEpisode + 1;

    if (nextEpisode > totalEpisodes) {
      KazumiDialog.showToast(message: '已经是最新一集');
      return;
    }

    final identifier = roadList[currentRoad].identifier[nextEpisode - 1];
    KazumiDialog.showToast(message: '正在加载$identifier');
    videoPageController.changeEpisode(nextEpisode, currentRoad: currentRoad);
  }

  void _onDanmakuToggle() {
    try {
      playerController.danmakuController.clear();
    } catch (e) {
      KazumiLogger().w('TVPlayerPage: failed to clear danmaku', error: e);
    }
    playerController.danmakuOn = !playerController.danmakuOn;
    _startControlsHideTimer();
  }

  void _openEpisodeMenu() {
    _controlsHideTimer?.cancel();
    setState(() {
      _isEpisodeMenuOpen = true;
      _isControlsVisible = false;
    });
  }

  void _closeEpisodeMenu() {
    setState(() {
      _isEpisodeMenuOpen = false;
    });
  }

  void _onEpisodeSelected(int episode) {
    videoPageController.changeEpisode(episode);
    _closeEpisodeMenu();
  }

  void _exitPlayer() {
    if (_isExiting) return;
    _isExiting = true;
    playerController.pause();
    Modular.to.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitPlayer();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Focus(
        focusNode: _pageFocusNode,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          children: [
            Center(
              child: PlayerItemSurface(),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: DanmakuScreen(
                key: _danmuKey,
                createdController: (DanmakuController e) {
                  playerController.danmakuController = e;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    playerController.updateDanmakuSpeed();
                  });
                },
                option: DanmakuOption(
                  hideTop: _hideTop,
                  hideScroll: _hideScroll,
                  hideBottom: _hideBottom,
                  area: _danmakuArea,
                  opacity: _opacity,
                  fontSize: _fontSize,
                  duration: _danmakuDuration / playerController.playerSpeed,
                  lineHeight: _danmakuLineHeight,
                  strokeWidth: _border ? _danmakuBorderSize : 0.0,
                  fontWeight: _danmakuFontWeight,
                  massiveMode: _massiveMode,
                  fontFamily:
                      _danmakuUseSystemFont ? null : customAppFontFamily,
                ),
              ),
            ),
            Observer(
              builder: (_) {
                final errorMsg = videoPageController.errorMessage;
                if (errorMsg == null) return const SizedBox.shrink();
                return Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          errorMsg,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '按确认键重试',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            TVProgressIndicator(
              isVisible: _isSeeking,
              direction: _seekDirection,
              amount: _seekStep,
            ),
            TVPlayerControls(
              isVisible: _isControlsVisible,
              focusNode: _controlsFocusNode,
              playerController: playerController,
              videoPageController: videoPageController,
              onPlayPause: _onPlayPause,
              onPreviousEpisode: _onPreviousEpisode,
              onNextEpisode: _onNextEpisode,
              onDanmakuToggle: _onDanmakuToggle,
              onEpisodeMenuOpen: _openEpisodeMenu,
              onHide: _hideControls,
              danmakuColor: _danmakuColor,
              danmakuBiliBiliSource: _danmakuBiliBiliSource,
              danmakuGamerSource: _danmakuGamerSource,
              danmakuDanDanSource: _danmakuDanDanSource,
            ),
            TVEpisodeMenu(
              isOpen: _isEpisodeMenuOpen,
              videoPageController: videoPageController,
              onEpisodeSelected: _onEpisodeSelected,
              onClose: _closeEpisodeMenu,
            ),
          ],
        ),
      ),
    ),
  );
  }
}

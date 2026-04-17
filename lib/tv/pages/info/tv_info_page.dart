import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'widgets/tv_info_left_panel.dart';
import 'widgets/tv_search_result_section.dart';
import 'package:kazumi/pages/info/info_controller.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/request/query_manager.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/tv/core/focus/tv_key_handler_new.dart';

class TVInfoPage extends StatefulWidget {
  final BangumiItem bangumiItem;

  const TVInfoPage({
    super.key,
    required this.bangumiItem,
  });

  @override
  State<TVInfoPage> createState() => _TVInfoPageState();
}

class _TVInfoPageState extends State<TVInfoPage> with TickerProviderStateMixin {
  late InfoController _infoController;
  late VideoPageController _videoPageController;
  late QueryManager _queryManager;

  final ScrollController _leftPanelScrollController = ScrollController();
  final FocusNode _pageFocusNode = FocusNode(debugLabel: 'info_page');
  final FocusNode _collectFocusNode = FocusNode(debugLabel: 'collect_btn');
  FocusNode? _rightPanelFirstFocusNode;
  bool _firstFocusNodeSet = false;

  static const double _scrollStep = 100.0;

  bool _searchCompleted = false;

  @override
  void initState() {
    super.initState();

    _infoController = InfoController();
    _infoController.bangumiItem = widget.bangumiItem;
    _infoController.characterList.clear();
    _infoController.commentsList.clear();
    _infoController.staffList.clear();
    _infoController.pluginSearchResponseList.clear();
    _videoPageController = Modular.get<VideoPageController>();
    _videoPageController.currentEpisode = 1;

    if (_infoController.bangumiItem.summary == '' ||
        _infoController.bangumiItem.votesCount.isEmpty) {
      _queryBangumiInfoByID(_infoController.bangumiItem.id, type: 'attach');
    }

    final keyword = widget.bangumiItem.nameCn.isNotEmpty
        ? widget.bangumiItem.nameCn
        : widget.bangumiItem.name;
    _queryManager = QueryManager(infoController: _infoController);

    _queryManager.queryAllSource(keyword);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _collectFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _infoController.characterList.clear();
    _infoController.commentsList.clear();
    _infoController.staffList.clear();
    _infoController.pluginSearchResponseList.clear();
    _videoPageController.currentEpisode = 1;
    _queryManager.cancel();
    _leftPanelScrollController.dispose();
    _collectFocusNode.dispose();
    _pageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _queryBangumiInfoByID(int id, {String type = 'init'}) async {
    try {
      await _infoController.queryBangumiInfoByID(id, type: type);
      setState(() {});
    } catch (e) {
      KazumiLogger()
          .e('TVInfoPage: failed to query bangumi info by ID', error: e);
    }
  }

  void _scrollLeftPanel(double offset) {
    if (!_leftPanelScrollController.hasClients) return;
    final maxScroll = _leftPanelScrollController.position.maxScrollExtent;
    final current = _leftPanelScrollController.offset;
    final target = (current + offset).clamp(0.0, maxScroll);
    _leftPanelScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _moveFocusToRightPanel() {
    if (_rightPanelFirstFocusNode != null) {
      _rightPanelFirstFocusNode!.requestFocus();
    }
  }

  void _onFirstFocusNodeReady(FocusNode node) {
    if (!_firstFocusNodeSet) {
      _rightPanelFirstFocusNode = node;
      _firstFocusNodeSet = true;
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    return TvKeyHandler.handleNavigation(
      event,
      onBack: () {
        Modular.to.pop();
        return KeyEventResult.handled;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _pageFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Observer(
          builder: (_) {
            if (!_searchCompleted &&
                _infoController.pluginSearchResponseList.isNotEmpty) {
              _searchCompleted = true;
            }

            return Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.4,
                  child: SingleChildScrollView(
                    controller: _leftPanelScrollController,
                    child: TVInfoLeftPanel(
                      bangumiItem: _infoController.bangumiItem,
                      collectFocusNode: _collectFocusNode,
                      onExitRight: _moveFocusToRightPanel,
                      onExitUp: () => _scrollLeftPanel(-_scrollStep),
                      onExitDown: () => _scrollLeftPanel(_scrollStep),
                    ),
                  ),
                ),
                Expanded(
                  child: TVSearchResultSection(
                    infoController: _infoController,
                    onPlayResult: _playSearchResult,
                    exitLeftFocusNode: _collectFocusNode,
                    onFirstFocusNodeReady: _onFirstFocusNodeReady,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _playSearchResult(String src, Plugin plugin) async {
    if (!mounted) return;

    KazumiDialog.showLoading(
      context: context,
      msg: '正在获取播放信息',
      barrierDismissible: false,
      onDismiss: () {
        _videoPageController.cancelQueryRoads();
      },
    );

    try {
      _videoPageController.bangumiItem = widget.bangumiItem;
      _videoPageController.currentPlugin = plugin;

      String title = widget.bangumiItem.nameCn.isNotEmpty
          ? widget.bangumiItem.nameCn
          : widget.bangumiItem.name;

      for (var response in _infoController.pluginSearchResponseList) {
        if (response.pluginName == plugin.name) {
          for (var searchItem in response.data) {
            if (searchItem.src == src) {
              title = searchItem.name;
              break;
            }
          }
          break;
        }
      }

      _videoPageController.title = title;
      _videoPageController.src = src;

      await _videoPageController.queryRoads(src, plugin.name);

      if (!mounted) return;
      KazumiDialog.dismiss();

      Modular.to.pushNamed('/player/');
    } catch (e) {
      if (!mounted) return;
      KazumiLogger().w('TVInfoPage: failed to query video playlist');
      KazumiDialog.dismiss();
      KazumiDialog.showToast(message: '播放失败，请重试', context: context);
    }
  }
}

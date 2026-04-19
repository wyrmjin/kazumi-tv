import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kazumi/pages/search/search_controller.dart';
import 'package:kazumi/tv/core/focus/tv_focus_scope.dart';
import 'package:kazumi/tv/core/focus/focus_pattern.dart';
import 'package:kazumi/tv/pages/search/widgets/tv_search_keyboard.dart';
import 'package:kazumi/tv/pages/search/widgets/tv_search_history.dart';
import 'package:kazumi/tv/pages/search/widgets/tv_search_results.dart';

class TVSearchPage extends StatefulWidget {
  const TVSearchPage({
    super.key,
    this.contentFocusNode,
    this.onExitToMenu,
  });

  final FocusNode? contentFocusNode;
  final VoidCallback? onExitToMenu;

  @override
  State<TVSearchPage> createState() => _TVSearchPageState();
}

class _TVSearchPageState extends State<TVSearchPage> {
  // 使用现有SearchPageController
  final SearchPageController _controller = SearchPageController();
  final ScrollController _scrollController = ScrollController();

  // TV特定状态
  String _searchText = '';
  bool _showResults = false;
  Timer? _debounceTimer;

  // 焦点管理
  final FocusNode _keyboardFocusNode = FocusNode();
  final FocusNode _rightFocusNode = FocusNode();

  FocusNode get _effectiveKeyboardNode =>
      widget.contentFocusNode ?? _keyboardFocusNode;

  @override
  void initState() {
    super.initState();
    _controller.loadSearchHistories();
    _scrollController.addListener(_scrollListener);

    // 初始焦点到键盘
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _effectiveKeyboardNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.bangumiList.clear();
    _debounceTimer?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _keyboardFocusNode.dispose();
    _rightFocusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_controller.isLoading &&
        _searchText.isNotEmpty &&
        _controller.bangumiList.length >= 20) {
      _controller.searchBangumi(_searchText, type: 'add');
    }
  }

  void _handleTextChanged(String text) {
    setState(() {
      _searchText = text;
    });

    _debounceTimer?.cancel();
    if (text.trim().isEmpty) {
      setState(() => _showResults = false);
      _controller.bangumiList.clear();
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _performSearch() {
    if (_searchText.trim().isEmpty) return;

    // 保存到搜索历史
    // TODO: SearchHistoryService.add(_searchText.trim());

    // 执行搜索
    _controller.searchBangumi(_searchText.trim(), type: 'new');

    // 切换到结果状态
    setState(() => _showResults = true);
  }

  void _handleSelectHistory(String keyword) {
    setState(() {
      _searchText = keyword;
    });
    _performSearch();
  }

  void _handleClearHistory() {
    _controller.searchHistories.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧键盘区域
          TVSearchKeyboard(
            searchText: _searchText,
            onTextChanged: _handleTextChanged,
            onExitLeft: widget.onExitToMenu,
            onExitRight: () => _rightFocusNode.requestFocus(),
            onBack: widget.onExitToMenu,
            keyboardFocusNode: widget.contentFocusNode ?? _keyboardFocusNode,
          ),

          // 右侧结果区域
          Expanded(
            child: Observer(
              builder: (_) => _buildRightArea(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightArea() {
    // 状态1: 显示搜索结果
    if (_showResults) {
      return TVSearchResults(
        results: _controller.bangumiList.toList(),
        scrollController: _scrollController,
        onLoadMore: () => _controller.searchBangumi(_searchText, type: 'add'),
        onBack: () => _effectiveKeyboardNode.requestFocus(),
        onExitLeft: () => _effectiveKeyboardNode.requestFocus(),
        firstItemFocusNode: _rightFocusNode,
      );
    }

    // 状态2: 有输入但搜索中
    if (_searchText.isNotEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFfb7299)),
      );
    }

    // 状态3: 初始状态显示历史
    return TvFocusScope(
      pattern: FocusPattern.vertical,
      onExitLeft: () => _effectiveKeyboardNode.requestFocus(),
      child: TVSearchHistory(
        history: _controller.searchHistories.map((h) => h.keyword).toList(),
        onSelect: _handleSelectHistory,
        onClear: _handleClearHistory,
        onBack: widget.onExitToMenu,
        onExitLeft: () => _effectiveKeyboardNode.requestFocus(),
        firstItemFocusNode: _rightFocusNode,
      ),
    );
  }
}

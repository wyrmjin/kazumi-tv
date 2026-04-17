import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazumi/tv/pages/search/tv_search_page.dart';
import 'package:kazumi/tv/pages/settings/tv_settings_page.dart';
import 'tv_menu_widget.dart';
import '../collect/tv_collect_page.dart';
import '../popular/tv_popular_page.dart';
import '../timeline/tv_timeline_page.dart';

/// TV 主页面
class TVMainPage extends StatefulWidget {
  const TVMainPage({super.key});

  @override
  State<TVMainPage> createState() => _TVMainPageState();
}

class _TVMainPageState extends State<TVMainPage> {
  int _selectedTabIndex = 0;
  final FocusNode _menuFocusNode = FocusNode();

  final List<FocusNode> _contentFocusNodes = [
    FocusNode(debugLabel: 'popular_content'),
    FocusNode(debugLabel: 'timeline_content'),
    FocusNode(debugLabel: 'collect_content'),
    FocusNode(debugLabel: 'search_content'),
    FocusNode(debugLabel: 'settings_content'),
  ];

  final List<Widget> _pages = [];
  final GlobalKey<TVMenuWidgetState> _menuKey = GlobalKey<TVMenuWidgetState>();

  @override
  void initState() {
    super.initState();
    _initPages();
  }

  @override
  void dispose() {
    _menuFocusNode.dispose();
    for (final node in _contentFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _initPages() {
    _pages.addAll([
      TVPopularPage(
        contentFocusNode: _contentFocusNodes[0],
        onExitToMenu: _handleExitToMenu,
      ),
      TVTimelinePage(
        contentFocusNode: _contentFocusNodes[1],
        onExitToMenu: _handleExitToMenu,
      ),
      TVCollectPage(
        contentFocusNode: _contentFocusNodes[2],
        onExitToMenu: _handleExitToMenu,
      ),
      TVSearchPage(
        contentFocusNode: _contentFocusNodes[3],
        onExitToMenu: _handleExitToMenu,
      ),
      TVSettingsPage(
        contentFocusNode: _contentFocusNodes[4],
        onExitToMenu: _handleExitToMenu,
      ),
    ]);
  }

  void _handleTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _handleExitToMenu() {
    _menuKey.currentState?.requestMenuFocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('退出应用'),
            content: const Text('确定要退出吗?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确定'),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Row(
          children: [
            TVMenuWidget(
              key: _menuKey,
              selectedIndex: _selectedTabIndex,
              onItemSelected: _handleTabSelected,
              onMenuItemFocused: (index) {
                _handleTabSelected(index);
              },
              onExitRight: () {
                final currentNode = _contentFocusNodes[_selectedTabIndex];
                currentNode.requestFocus();
              },
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

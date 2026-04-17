import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/modules/plugin/plugin_http_module.dart';
import 'package:kazumi/tv/core/focus/tv_list_items.dart';
import 'package:kazumi/tv/core/utils/tv_constants.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';

class TVPluginShopPage extends StatefulWidget {
  final FocusNode? sidebarFocusNode;

  const TVPluginShopPage({
    super.key,
    this.sidebarFocusNode,
  });

  @override
  State<TVPluginShopPage> createState() => _TVPluginShopPageState();
}

class _TVPluginShopPageState extends State<TVPluginShopPage> {
  final PluginsController pluginsController = Modular.get<PluginsController>();
  bool _isLoading = true;
  late final FocusNode _refreshFocusNode;

  @override
  void initState() {
    super.initState();
    _refreshFocusNode = FocusNode(debugLabel: 'refresh_btn');
    _loadPlugins();
  }

  @override
  void dispose() {
    _refreshFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadPlugins() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await pluginsController.queryPluginHTTPList();
    } catch (e) {
      if (mounted) {
        KazumiDialog.showToast(
          message: '加载插件列表失败: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: TVConstants.focusColor,
        ),
      );
    }

    return Observer(
      builder: (_) {
        if (pluginsController.pluginHTTPList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '暂无可用插件',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TvVerticalListItem(
                  focusNode: _refreshFocusNode,
                  autofocus: true,
                  onSelect: _loadPlugins,
                  onFocusChange: (hasFocus) => setState(() {}),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _refreshFocusNode.hasFocus
                          ? TVConstants.focusColor
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: _refreshFocusNode.hasFocus
                          ? Border.all(
                              color: TVConstants.focusColor,
                              width: 2,
                            )
                          : null,
                    ),
                    child: const Text(
                      '刷新',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pluginsController.pluginHTTPList.length,
          itemBuilder: (context, index) {
            final pluginHTTPItem = pluginsController.pluginHTTPList[index];
            return _PluginShopCard(
              pluginHTTPItem: pluginHTTPItem,
              pluginsController: pluginsController,
              autofocus: index == 0,
            );
          },
        );
      },
    );
  }
}

class _PluginShopCard extends StatefulWidget {
  final PluginHTTPItem pluginHTTPItem;
  final PluginsController pluginsController;
  final bool autofocus;

  const _PluginShopCard({
    required this.pluginHTTPItem,
    required this.pluginsController,
    this.autofocus = false,
  });

  @override
  State<_PluginShopCard> createState() => _PluginShopCardState();
}

class _PluginShopCardState extends State<_PluginShopCard> {
  late final FocusNode _cardFocusNode;
  late final FocusNode _actionFocusNode;

  @override
  void initState() {
    super.initState();
    _cardFocusNode = FocusNode(debugLabel: 'plugin_shop_card');
    _actionFocusNode = FocusNode(debugLabel: 'plugin_action_btn');
  }

  @override
  void dispose() {
    _cardFocusNode.dispose();
    _actionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.pluginsController.pluginStatus(widget.pluginHTTPItem);

    return TvVerticalListItem(
      focusNode: _cardFocusNode,
      autofocus: widget.autofocus,
      onSelect: () {},
      onFocusChange: (hasFocus) => setState(() {}),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _cardFocusNode.hasFocus
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: _cardFocusNode.hasFocus
              ? Border.all(color: TVConstants.focusColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pluginHTTPItem.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TVConstants.focusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.pluginHTTPItem.version,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildActionButton(status),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String status) {
    if (status == 'installed') {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(50),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '已安装',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    return TvVerticalListItem(
      focusNode: _actionFocusNode,
      onSelect: () => _handleInstall(),
      onFocusChange: (hasFocus) => setState(() {}),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _actionFocusNode.hasFocus
              ? TVConstants.focusColor
              : TVConstants.focusColor.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status == 'update' ? '更新' : '安装',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _handleInstall() async {
    await KazumiDialog.showLoading(
      msg: '正在安装 ${widget.pluginHTTPItem.name}...',
    );

    try {
      final plugin = await widget.pluginsController
          .queryPluginHTTP(widget.pluginHTTPItem.name);
      if (plugin != null) {
        widget.pluginsController.updatePlugin(plugin);
        KazumiDialog.dismiss();

        if (mounted) {
          KazumiDialog.showToast(
            message: '成功安装 ${widget.pluginHTTPItem.name}',
          );
        }
      } else {
        KazumiDialog.dismiss();
        if (mounted) {
          KazumiDialog.showToast(
            message: '安装失败：无法获取插件信息',
          );
        }
      }
    } catch (e) {
      KazumiDialog.dismiss();
      if (mounted) {
        KazumiDialog.showToast(
          message: '安装失败: $e',
        );
      }
    }
  }
}

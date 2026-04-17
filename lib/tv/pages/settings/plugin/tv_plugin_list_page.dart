import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/tv/pages/settings/widgets/tv_plugin_card.dart';
import 'package:kazumi/tv/core/focus/tv_list_items.dart';
import 'package:kazumi/tv/core/utils/tv_constants.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';

class TVPluginListPage extends StatefulWidget {
  final FocusNode? firstItemFocusNode;
  final VoidCallback? onExitUp;
  final FocusNode? sidebarFocusNode;

  const TVPluginListPage({
    super.key,
    this.firstItemFocusNode,
    this.onExitUp,
    this.sidebarFocusNode,
  });

  @override
  State<TVPluginListPage> createState() => _TVPluginListPageState();
}

class _TVPluginListPageState extends State<TVPluginListPage> {
  final PluginsController pluginsController = Modular.get<PluginsController>();
  late final FocusNode _updateAllFocusNode;
  late final FocusNode _pluginShopFocusNode;
  late final bool _ownsUpdateAllNode;

  @override
  void initState() {
    super.initState();
    _ownsUpdateAllNode = widget.firstItemFocusNode == null;
    _updateAllFocusNode = widget.firstItemFocusNode ?? FocusNode(debugLabel: 'update_all_btn');
    _pluginShopFocusNode = FocusNode(debugLabel: 'plugin_shop_btn');
  }

  @override
  void dispose() {
    if (_ownsUpdateAllNode) {
      _updateAllFocusNode.dispose();
    }
    _pluginShopFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopButtons(),
        Expanded(
          child: Observer(
            builder: (_) {
              if (pluginsController.pluginList.isEmpty) {
                return const Center(
                  child: Text(
                    '暂无已安装的插件',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: pluginsController.pluginList.length,
                itemBuilder: (context, index) {
                  final plugin = pluginsController.pluginList[index];
                  return TVPluginCard(
                    plugin: plugin,
                    autofocus: index == 0,
                    onDelete: () => _handleDeletePlugin(plugin),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          TvHorizontalListItem(
            focusNode: _updateAllFocusNode,
            autofocus: true,
            exitRight: _pluginShopFocusNode,
            onMoveUp: widget.onExitUp,
            isFirst: true,
            onSelect: _handleUpdateAll,
            onFocusChange: (hasFocus) => setState(() {}),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _updateAllFocusNode.hasFocus
                    ? TVConstants.focusColor
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: _updateAllFocusNode.hasFocus
                    ? Border.all(color: TVConstants.focusColor, width: 2)
                    : null,
              ),
              child: const Text(
                '更新全部',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          TvHorizontalListItem(
            focusNode: _pluginShopFocusNode,
            exitLeft: _updateAllFocusNode,
            isFirst: false,
            isLast: true,
            onSelect: () {
              Modular.to.pushNamed('/settings/plugin/shop');
            },
            onFocusChange: (hasFocus) => setState(() {}),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _pluginShopFocusNode.hasFocus
                    ? TVConstants.focusColor
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: _pluginShopFocusNode.hasFocus
                    ? Border.all(color: TVConstants.focusColor, width: 2)
                    : null,
              ),
              child: const Text(
                '插件商店',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdateAll() async {
    await KazumiDialog.showLoading(
      msg: '正在更新插件...',
    );

    try {
      final count = await pluginsController.tryUpdateAllPlugin();
      KazumiDialog.dismiss();

      if (mounted) {
        if (count > 0) {
          KazumiDialog.showToast(
            message: '成功更新 $count 个插件',
          );
        } else {
          KazumiDialog.showToast(
            message: '没有需要更新的插件',
          );
        }
      }
    } catch (e) {
      KazumiDialog.dismiss();
      if (mounted) {
        KazumiDialog.showToast(
          message: '更新失败: $e',
        );
      }
    }
  }

  Future<void> _handleDeletePlugin(Plugin plugin) async {
    final confirmed = await KazumiDialog.show<bool>(
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除插件 "${plugin.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await pluginsController.removePlugin(plugin);
      if (mounted) {
        KazumiDialog.showToast(
          message: '已删除插件 ${plugin.name}',
        );
      }
    }
  }
}

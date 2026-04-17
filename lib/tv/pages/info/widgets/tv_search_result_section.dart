import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/info/info_controller.dart';

import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/plugins/plugins.dart';
import 'package:kazumi/plugins/anti_crawler_config.dart';
import 'package:kazumi/providers/captcha/captcha_provider.dart';
import 'package:kazumi/request/query_manager.dart';
import 'package:kazumi/modules/search/plugin_search_module.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import '../../../core/widgets/tv_button.dart';
import '../../../core/focus/tv_list_items.dart';
import 'tv_search_result_card.dart';
import 'tv_captcha_keyboard.dart';

/// TV 番剧详情页右侧搜索结果区
class TVSearchResultSection extends StatefulWidget {
  final InfoController infoController;
  final void Function(String src, Plugin plugin)? onPlayResult;
  final FocusNode? exitLeftFocusNode;
  final void Function(FocusNode firstNode)? onFirstFocusNodeReady;

  const TVSearchResultSection({
    super.key,
    required this.infoController,
    this.onPlayResult,
    this.exitLeftFocusNode,
    this.onFirstFocusNodeReady,
  });

  @override
  State<TVSearchResultSection> createState() => _TVSearchResultSectionState();
}

class _TVSearchResultSectionState extends State<TVSearchResultSection> {
  final PluginsController pluginsController = Modular.get<PluginsController>();
  QueryManager? queryManager;
  late String keyword;

  CaptchaProvider? _captchaProvider;
  Timer? _captchaVerifyTimer;
  final Map<String, List<FocusNode>> _pluginResultFocusNodes = {};

  @override
  void initState() {
    super.initState();
    keyword = widget.infoController.bangumiItem.nameCn.isEmpty
        ? widget.infoController.bangumiItem.name
        : widget.infoController.bangumiItem.nameCn;
    queryManager = QueryManager(infoController: widget.infoController);
    queryManager?.queryAllSource(keyword);
  }

  @override
  void dispose() {
    queryManager?.cancel();
    queryManager = null;
    _captchaProvider?.dispose();
    _captchaProvider = null;
    _captchaVerifyTimer?.cancel();
    _captchaVerifyTimer = null;
    for (final nodes in _pluginResultFocusNodes.values) {
      for (final node in nodes) {
        node.dispose();
      }
    }
    _pluginResultFocusNodes.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Observer(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: _buildPluginList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          '搜索结果',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 16),
        Observer(
          builder: (context) {
            final pendingCount = widget.infoController.pluginSearchStatus.values
                .where((status) => status == 'pending')
                .length;
            if (pendingCount > 0) {
              return Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '正在检索 $pendingCount 个插件...',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildPluginList() {
    if (pluginsController.pluginList.isEmpty) {
      return const Center(
        child: Text(
          '没有可用的插件',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final visiblePlugins = pluginsController.pluginList.where((plugin) {
      final status = widget.infoController.pluginSearchStatus[plugin.name];
      return status != 'error' && status != 'noResult';
    }).toList();

    if (visiblePlugins.isEmpty) {
      return const Center(
        child: Text(
          '正在搜索中...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: visiblePlugins.length,
      itemBuilder: (context, index) {
        final plugin = visiblePlugins[index];
        return _buildPluginSection(plugin);
      },
    );
  }

  Widget _buildPluginSection(Plugin plugin) {
    return Observer(
      builder: (context) {
        final status = widget.infoController.pluginSearchStatus[plugin.name];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPluginHeader(plugin, status),
              const SizedBox(height: 12),
              _buildPluginContent(plugin, status),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPluginHeader(Plugin plugin, String? status) {
    return Row(
      children: [
        Text(
          plugin.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusBadge(status),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    switch (status) {
      case 'pending':
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case 'captcha':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '需要验证',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
        );
      case 'noResult':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '无结果',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      case 'error':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '错误',
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        );
      case 'success':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '成功',
            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPluginContent(Plugin plugin, String? status) {
    if (status == 'pending') {
      return _buildPendingState();
    }

    if (status == 'captcha') {
      return _buildCaptchaState(plugin);
    }

    return _buildSuccessState(plugin);
  }

  Widget _buildPendingState() {
    return Container(
      height: 80,
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            '正在搜索...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptchaState(Plugin plugin) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${plugin.name} 需要验证码验证',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(
            width: 100,
            height: 48,
            child: TVButton(
              onTap: () => _showCaptchaDialog(plugin),
              child: const Center(child: Text('验证')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(Plugin plugin) {
    final searchResults = widget.infoController.pluginSearchResponseList
        .where((response) => response.pluginName == plugin.name)
        .toList();

    if (searchResults.isEmpty || searchResults.first.data.isEmpty) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: const Text(
          '无搜索结果',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    final results = searchResults.first.data;

    if (!_pluginResultFocusNodes.containsKey(plugin.name)) {
      _pluginResultFocusNodes[plugin.name] = [];
    }
    final focusNodes = _pluginResultFocusNodes[plugin.name]!;
    while (focusNodes.length < results.length) {
      focusNodes.add(
          FocusNode(debugLabel: '${plugin.name}_result_${focusNodes.length}'));
    }
    while (focusNodes.length > results.length) {
      focusNodes.removeLast().dispose();
    }

    if (focusNodes.isNotEmpty) {
      widget.onFirstFocusNodeReady?.call(focusNodes[0]);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(results.length, (index) {
        final item = results[index];

        return Container(
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TvGridItem(
            focusNode: focusNodes[index],
            index: index,
            crossAxisCount: 1,
            totalItems: results.length,
            exitLeft: widget.exitLeftFocusNode,
            onExitLeft: () => widget.exitLeftFocusNode?.requestFocus(),
            onSelect: () => _onResultTap(item, plugin),
            onFocusChange: (hasFocus) => setState(() {}),
            child: TVSearchResultCard(
              title: item.name,
              isFocused: focusNodes[index].hasFocus,
              onSelect: () => _onResultTap(item, plugin),
            ),
          ),
        );
      }),
    );
  }

  void _onResultTap(SearchItem item, Plugin plugin) {
    widget.onPlayResult?.call(item.src, plugin);
  }

  void _showCaptchaDialog(Plugin plugin) {
    switch (plugin.antiCrawlerConfig.captchaType) {
      case CaptchaType.autoClickButton:
        _showButtonClickDialog(plugin);
        break;
      default:
        _showImageCaptchaDialog(plugin);
    }
  }

  void _showImageCaptchaDialog(Plugin plugin) {
    final captchaImageNotifier = ValueNotifier<String?>(null);
    final submittingNotifier = ValueNotifier<bool>(false);
    final codeNotifier = ValueNotifier<String>('');
    bool verified = false;

    _captchaProvider?.dispose();
    _captchaProvider = CaptchaProvider();

    final searchUrl = plugin.searchURL
        .replaceAll('@keyword', Uri.encodeQueryComponent(keyword));

    _captchaProvider!.loadForCaptcha(
      searchUrl,
      plugin.antiCrawlerConfig.captchaImage,
      inputXpath: plugin.antiCrawlerConfig.captchaInput,
    );

    final imageSub = _captchaProvider!.onCaptchaImageUrl.listen((url) {
      if (url != null) captchaImageNotifier.value = url;
    });

    Future<void> doSubmit() async {
      if (submittingNotifier.value) return;
      if (codeNotifier.value.trim().isEmpty) {
        KazumiDialog.showToast(message: '请输入验证码');
        return;
      }
      submittingNotifier.value = true;
      await _captchaProvider?.submitCaptcha(
        captchaCode: codeNotifier.value.trim(),
        inputXpath: plugin.antiCrawlerConfig.captchaInput,
        buttonXpath: plugin.antiCrawlerConfig.captchaButton,
        pluginName: plugin.name,
        onVerified: () {
          _captchaVerifyTimer?.cancel();
          _captchaVerifyTimer = null;
          verified = true;
          Navigator.of(context).pop();
          KazumiDialog.showTimedSuccessDialog(
            title: '验证成功',
            message: '正在重新检索，请稍候…',
            onComplete: () => queryManager?.querySource(keyword, plugin.name),
          );
        },
      );
      if (!verified) {
        _captchaVerifyTimer?.cancel();
        _captchaVerifyTimer = Timer(const Duration(seconds: 8), () {
          if (!verified) {
            Navigator.of(context).pop();
          }
        });
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '验证码验证',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${plugin.name} 需要验证码验证'),
                const SizedBox(height: 16),
                ValueListenableBuilder<String?>(
                  valueListenable: captchaImageNotifier,
                  builder: (context, imageUrl, _) {
                    if (imageUrl == null) {
                      return const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('正在加载验证码图片...'),
                        ],
                      );
                    }
                    return ValueListenableBuilder<bool>(
                      valueListenable: submittingNotifier,
                      builder: (context, isSubmitting, _) {
                        return ValueListenableBuilder<String>(
                          valueListenable: codeNotifier,
                          builder: (context, codeText, _) {
                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(imageUrl.split(',').last),
                                    height: 60,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, _) =>
                                        const Text('图片解码失败'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TVCaptchaKeyboard(
                                  text: codeText,
                                  onTextChanged: (val) {
                                    codeNotifier.value = val;
                                  },
                                  onSubmit: doSubmit,
                                  onCancel: () => Navigator.of(context).pop(),
                                  onBack: () => Navigator.of(context).pop(),
                                  enabled: !isSubmitting,
                                ),
                            if (isSubmitting)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                );
                  },
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _captchaVerifyTimer?.cancel();
      _captchaVerifyTimer = null;
      imageSub.cancel();
      codeNotifier.dispose();
      captchaImageNotifier.dispose();
      submittingNotifier.dispose();
      final provider = _captchaProvider;
      _captchaProvider = null;
      if (!verified) {
        provider?.saveAndUnload(plugin.name).then((_) {
          provider.dispose();
          queryManager?.querySource(keyword, plugin.name);
        });
      } else {
        provider?.dispose();
      }
    });
  }

  void _showButtonClickDialog(Plugin plugin) {
    bool autoVerified = false;

    _captchaProvider?.dispose();
    _captchaProvider = CaptchaProvider();

    final searchUrl = plugin.searchURL
        .replaceAll('@keyword', Uri.encodeQueryComponent(keyword));

    void onVerified() {
      if (autoVerified) return;
      autoVerified = true;
      Navigator.of(context).pop();
      KazumiDialog.showTimedSuccessDialog(
        title: '验证成功',
        message: '正在重新检索，请稍候…',
        onComplete: () => queryManager?.querySource(keyword, plugin.name),
      );
    }

    _captchaProvider!.loadForButtonClick(
      url: searchUrl,
      buttonXpath: plugin.antiCrawlerConfig.captchaButton,
      pluginName: plugin.name,
      onVerified: onVerified,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '自动验证中',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${plugin.name} 正在自动完成验证，请稍候',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                const Text(
                  '已检测到验证按钮并模拟点击，等待验证通过…',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: TVButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Center(child: Text('取消')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) async {
      final provider = _captchaProvider;
      _captchaProvider = null;
      if (autoVerified) {
        provider?.dispose();
      } else {
        await provider?.saveAndUnload(plugin.name);
        provider?.dispose();
        queryManager?.querySource(keyword, plugin.name);
      }
    });
  }
}

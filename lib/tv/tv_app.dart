import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';
import 'core/utils/tv_constants.dart';

/// TV 应用入口
class TVApp extends StatefulWidget {
  const TVApp({super.key});

  @override
  State<TVApp> createState() => _TVAppState();
}

class _TVAppState extends State<TVApp> {
  @override
  void initState() {
    super.initState();
    initTVEnvironment();
  }

  @override
  Widget build(BuildContext context) {
    Modular.setObservers([KazumiDialog.observer]);
    return MaterialApp.router(
      title: 'Kazumi TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: TVConstants.focusColor,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: TVConstants.focusColor,
          secondary: TVConstants.focusColor,
          surface: Colors.black,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: TVConstants.titleFontSize,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: TVConstants.subtitleFontSize,
            color: Colors.white70,
          ),
        ),
      ),
      routerConfig: Modular.routerConfig,
    );
  }
}

/// 初始化 TV 环境
Future<void> initTVEnvironment() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;

  PaintingBinding.instance.imageCache.maximumSize =
      TVConstants.maxImageCacheSize;
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      TVConstants.maxImageCacheBytes;

  // 设置 TV 默认配置
  final setting = GStorage.setting;
  if (setting.get(SettingBoxKey.autoPlayNext) == null) {
    await setting.put(SettingBoxKey.autoPlayNext, true);
  }
  if (setting.get(SettingBoxKey.playResume) == null) {
    await setting.put(SettingBoxKey.playResume, true);
  }
  if (setting.get(SettingBoxKey.danmakuBiliBiliSource) == null) {
    await setting.put(SettingBoxKey.danmakuBiliBiliSource, true);
  }
  if (setting.get(SettingBoxKey.danmakuGamerSource) == null) {
    await setting.put(SettingBoxKey.danmakuGamerSource, true);
  }
  if (setting.get(SettingBoxKey.danmakuDanDanSource) == null) {
    await setting.put(SettingBoxKey.danmakuDanDanSource, true);
  }
  if (setting.get(SettingBoxKey.defaultStartupPage) == null) {
    await setting.put(SettingBoxKey.defaultStartupPage, '/tab/popular/');
  }
  if (setting.get(SettingBoxKey.enableGitProxy) == null) {
    await setting.put(SettingBoxKey.enableGitProxy, true);
  }

  final pluginsController = Modular.get<PluginsController>();
  try {
    await pluginsController.init();
    if (pluginsController.pluginList.isEmpty) {
      await pluginsController.copyPluginsToExternalDirectory();
    }
    await pluginsController.installAndUpdateAllPlugins();
  } catch (e) {
    KazumiLogger().e('TV: plugin init failed', error: e);
  }
}

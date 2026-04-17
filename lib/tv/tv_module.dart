import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/collect/collect_controller.dart';
import 'package:kazumi/pages/download/download_controller.dart';
import 'package:kazumi/pages/history/history_controller.dart';
import 'package:kazumi/pages/info/info_controller.dart';
import 'package:kazumi/pages/my/my_controller.dart';
import 'package:kazumi/pages/popular/popular_controller.dart';
import 'package:kazumi/pages/timeline/timeline_controller.dart';
import 'package:kazumi/pages/video/video_controller.dart';
import 'package:kazumi/plugins/plugins_controller.dart';
import 'package:kazumi/repositories/collect_crud_repository.dart';
import 'package:kazumi/repositories/collect_repository.dart';
import 'package:kazumi/repositories/download_repository.dart';
import 'package:kazumi/repositories/history_repository.dart';
import 'package:kazumi/repositories/search_history_repository.dart';
import 'package:kazumi/shaders/shaders_controller.dart';
import 'package:kazumi/tv/pages/settings/tv_settings_module.dart';
import 'package:kazumi/utils/download_manager.dart';
import 'pages/collect/tv_collect_module.dart';
import 'pages/info/tv_info_module.dart';
import 'pages/main/tv_main_module.dart';
import 'pages/player/tv_player_module.dart';
import 'pages/popular/tv_popular_module.dart';
import 'pages/search/tv_search_module.dart';
import 'pages/timeline/tv_timeline_module.dart';

class TVModule extends Module {
  @override
  void binds(i) {
    i.addSingleton<ICollectRepository>(CollectRepository.new);
    i.addSingleton<ISearchHistoryRepository>(SearchHistoryRepository.new);
    i.addSingleton<ICollectCrudRepository>(CollectCrudRepository.new);
    i.addSingleton<IHistoryRepository>(HistoryRepository.new);
    i.addSingleton<IDownloadRepository>(DownloadRepository.new);
    i.addSingleton<IDownloadManager>(DownloadManager.new);

    i.addSingleton(PopularController.new);
    i.addSingleton(PluginsController.new);
    i.addSingleton(VideoPageController.new);
    i.addSingleton(TimelineController.new);
    i.addSingleton(CollectController.new);
    i.addSingleton(HistoryController.new);
    i.addSingleton(MyController.new);
    i.addSingleton(ShadersController.new);
    i.addSingleton(DownloadController.new);
    i.addSingleton(InfoController.new);
  }

  @override
  void routes(r) {
    r.module("/", module: TVMainModule());
    r.module("/popular", module: TVPopularModule());
    r.module("/timeline", module: TVTimelineModule());
    r.module("/collect", module: TVCollectModule());
    r.module("/search", module: TVSearchModule());
    r.module("/settings", module: TVSettingsModule());
    r.module("/info", module: TVInfoModule());
    r.module("/player", module: TVPlayerModule());
  }
}

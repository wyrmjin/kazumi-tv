import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/tv/pages/settings/plugin/tv_plugin_list_page.dart';
import 'package:kazumi/tv/pages/settings/plugin/tv_plugin_shop_page.dart';

class TVPluginModule extends Module {
  @override
  void routes(r) {
    r.child("/", child: (_) => const TVPluginListPage());
    r.child("/shop", child: (_) => const TVPluginShopPage());
  }
}

import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/tv/pages/settings/tv_settings_page.dart';
import 'package:kazumi/tv/pages/settings/plugin/tv_plugin_module.dart';

class TVSettingsModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const TVSettingsPage());
    r.module('/plugin', module: TVPluginModule());
  }
}

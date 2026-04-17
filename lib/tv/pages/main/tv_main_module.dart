import 'package:flutter_modular/flutter_modular.dart';
import 'tv_main_page.dart';

class TVMainModule extends Module {
  @override
  void routes(r) {
    r.child("/", child: (_) => const TVMainPage());
  }
}

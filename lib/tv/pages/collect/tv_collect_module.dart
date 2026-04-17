import 'package:flutter_modular/flutter_modular.dart';
import 'tv_collect_page.dart';

class TVCollectModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const TVCollectPage());
  }
}

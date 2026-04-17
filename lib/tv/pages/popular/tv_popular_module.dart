import 'package:flutter_modular/flutter_modular.dart';
import 'tv_popular_page.dart';

class TVPopularModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const TVPopularPage());
  }
}

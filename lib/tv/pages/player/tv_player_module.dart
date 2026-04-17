import 'package:flutter_modular/flutter_modular.dart';
import '../../../pages/player/player_controller.dart';
import 'tv_player_page.dart';

class TVPlayerModule extends Module {
  @override
  void routes(r) {
    r.child("/", child: (_) => const TVPlayerPage());
  }

  @override
  void binds(i) {
    i.addSingleton(PlayerController.new);
  }
}

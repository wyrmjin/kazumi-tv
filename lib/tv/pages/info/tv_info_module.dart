import 'package:flutter_modular/flutter_modular.dart';
import 'tv_info_page.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';

class TVInfoModule extends Module {
  @override
  void routes(r) {
    r.child(
      "/",
      child: (_) {
        final bangumiItem = r.args.data as BangumiItem;
        return TVInfoPage(bangumiItem: bangumiItem);
      },
    );
  }
}

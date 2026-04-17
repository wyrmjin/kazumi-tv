import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kazumi/tv/tv_app.dart';
import 'package:kazumi/tv/tv_module.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/request/request.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hivePath = '${(await getApplicationSupportDirectory()).path}/hive';
  await Hive.initFlutter(hivePath);
  await GStorage.init();

  Request();
  await Request.setCookie();

  initTVEnvironment();

  runApp(
    ModularApp(
      module: TVModule(),
      child: const TVApp(),
    ),
  );
}

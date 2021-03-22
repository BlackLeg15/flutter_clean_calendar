import 'package:example/app/app_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:example/app/modules/home/home_module.dart';

class AppModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.singleton((i) => AppController()),
  ];

  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/', module: HomeModule()),
  ];
}

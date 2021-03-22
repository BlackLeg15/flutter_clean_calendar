import 'package:example/app/modules/home/home_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:example/app/modules/home/home_page.dart';

class HomeModule extends Module {
  @override
  final List<Bind> binds = [
    Bind((i) => HomeController()),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, args) => HomePage()),
  ];
}

import 'package:flutter/widgets.dart' hide Router;
import 'package:app/framework.dart';

typedef ModuleInitializer = Future<Module> Function( BuildContext context );

class ModuleProvider extends InheritedWidget {

  final Module module;
  final dynamic arguments;

  const ModuleProvider._( this.module, this.arguments, { required super.child, super.key } );

  factory ModuleProvider( {
    required Module module,
    Widget widget = const SizedBox(),
    dynamic arguments,
    Key? key,
  } ) {

    return ModuleProvider._(
      module,
      arguments,
      key: key ?? UniqueKey(),
      child: widget,
    );
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
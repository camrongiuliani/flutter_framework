import 'package:element_tree_child_locator/element_tree_child_locator.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:app/framework.dart';
import 'package:lenient_equality/lenient_equality.dart';

extension AppContextExt on BuildContext {

  Module get module => Module.of( this );

  BuildContext get scaffold => Scaffold.of( this ).context;

  BuildContext? get appBar => () {
    if ( widget is! Scaffold ) {
      return scaffold.findFirstChildElementForWidgetOfType<AppBarProxy>();
    }
    return findFirstChildElementForWidgetOfType<AppBarProxy>();
  }();

  ModalRoute? get currentRoute {
    Application app = Application.of( this );
    BuildContext? appCtx = app.router.key.currentContext;
    BuildContext? moduleCtx = app.activeProvider?.module.key.currentContext;

    return ModalRoute.of( ( moduleCtx ?? appCtx ) ?? this );
  }

  ModuleProvider lookupActiveModuleProvider() {

    Application app = Application.of( this );

    Element? moduleProvider = app.router.key.currentContext?.findLastChildElementsMatching( ( el ) {
      var isProvider = el.widget is ModuleProvider;
      var route = ModalRoute.of( el );
      var isCurrent = route?.isCurrent == true;
      var hasRoute = ! isNullOrEmpty( route?.settings.name );

      return isProvider && isCurrent && hasRoute;
    });

    return (moduleProvider!.widget as ModuleProvider);
  }

}
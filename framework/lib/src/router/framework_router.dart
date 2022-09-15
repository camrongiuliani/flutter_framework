


import 'package:app/framework.dart';
import 'package:flutter/cupertino.dart';

class FrameworkNavigator {

  final GlobalKey<NavigatorState> key;

  final Application application;

  FrameworkNavigator( this.application ) : key = GlobalKey<NavigatorState>( debugLabel: 'Root Navigator' );

  Route<dynamic>? generateRoute( RouteSettings settings ) {
    for ( var module in application.modules ) {
      if ( module.canHandleRoute( settings.name ) ) {

        ContentRoute request = module.routes.firstWhere( ( r ) => r.routeName == settings.name );

        bool guarded = module.checkGuard( request );

        if ( module.navigator != null ) {
          return CupertinoPageRoute( settings: settings, builder: (_) => request.builder() );
        } else {
          Widget moduleWidget = ModuleProvider(
            module: module,
            widget: ModuleWidget(
              module: module,
              initialRoute: settings.name!,
              key: UniqueKey(),
            ),
          );

          return CupertinoPageRoute(
            settings: settings,
            builder: ( context ) => moduleWidget,
          );
        }
      }
    }

    return null;
  }

  bool _moduleCanHandle( String routeName ) {
    return application.activeModule?.canHandleRoute( routeName ) ?? false;
  }

  NavigatorState _getRouter( String routeName ) {
    if ( _moduleCanHandle( routeName ) == true ) {
      var mState = application.activeModule?.key.currentState;

      if ( mState != null ) {
        return mState;
      }
    }

    // App key state should never be null at this point.
    return application.router.key.currentState!;
  }

  Future<T?> pushNamed<T extends Object?>( String routeName, { Object? arguments }) async {
    await application.activeModule?.willPush( routeName );

    return _getRouter( routeName ).pushNamed( routeName, arguments: arguments );
  }

  Future<bool> shouldPop( BuildContext context ) async {
    Module? module = application.activeModule;
    BuildContext? ctx = module?.key.currentContext;

    if ( ctx != null ) {
      ModalRoute? route = ModalRoute.of( ctx );

      if ( route != null ) {
        return await module!.shouldPop( route.settings.name!, ctx );
      }
    }

    return key.currentState?.canPop() == true;
  }

  void pop<T>([ T? result ]) {
    var module = application.activeModule;
    var moduleState = module?.key.currentState;

    if ( moduleState?.canPop() == true ) {
      module!.willPop().then((_) {
        moduleState!.pop( result );
      });

      return;
    }

    var appState = application.router.key.currentState;

    if ( appState?.canPop() == true ) {
      application.willPop().then((_) {
        appState!.pop( result );
      });
    }
  }
}
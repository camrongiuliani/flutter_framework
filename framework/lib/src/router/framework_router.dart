


import 'package:app/framework.dart';
import 'package:flutter/cupertino.dart';

class FrameworkNavigator {

  final GlobalKey<NavigatorState> key;

  final Application application;

  static FrameworkNavigator? instance;

  FrameworkNavigator._( this.application ) : key = GlobalKey<NavigatorState>( debugLabel: 'Root Navigator' );

  factory FrameworkNavigator( [ Application? application ] ) {
    assert( instance != null || application != null, 'Invalid call to FrameworkNavigator. Must pass application or have existing instance.' );
    return instance ??= FrameworkNavigator._( application! );
  }

  Route<dynamic>? generateRoute( RouteSettings settings ) {
    for ( var module in application.modules ) {
      if ( module.canHandleRoute( settings.name ) ) {
        if ( module.navigator != null ) {
          return CupertinoPageRoute( settings: settings, builder: ( context ) {
            return module.routes
                .firstWhere( ( r ) => r.routeName == settings.name )
                .builder();
          });
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
    return application.activeProvider?.module.canHandleRoute( routeName ) ?? false;
  }

  NavigatorState _getRouter( String routeName ) {
    if ( _moduleCanHandle( routeName ) == true ) {
      var mState = application.activeProvider?.module.key.currentState;

      if ( mState != null ) {
        return application.activeProvider!.module.key.currentState!;
      }
    }

    // App key state should never be null at this point.
    return application.router.key.currentState!;
  }

  Future<T?> pushNamed<T extends Object?>( String routeName, { Object? arguments }) async {
    await application.activeProvider?.module.willPush( routeName );

    return _getRouter( routeName ).pushNamed( routeName, arguments: arguments );
  }

  Future<bool> shouldPop( BuildContext context ) async {
    ModuleProvider? mp = application.activeProvider;
    BuildContext? ctx = mp?.module.key.currentContext;

    if ( ctx != null ) {
      ModalRoute? route = ModalRoute.of( ctx );

      if ( route != null ) {
        return await mp!.module.shouldPop( route.settings.name!, ctx );
      }
    }

    return key.currentState?.canPop() == true;
  }

  void pop<T>([ T? result ]) {
    var module = application.activeProvider?.module;
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
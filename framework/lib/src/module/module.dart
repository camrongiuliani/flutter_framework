library meetri_core;

import 'dart:async';
import 'package:abstract_kv_store/abstract_kv_store.dart';
import 'package:app/src/models/framework_component.dart';
import 'package:element_tree_child_locator/element_tree_child_locator.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/widgets.dart' hide Router;
import 'package:app/framework.dart';
import 'package:lenient_equality/lenient_equality.dart';

class Module extends FrameworkComponent {

  final Application application;
  final List<ContentRoute> routes = [];
  final List<ContentSlice> slices = [];
  final Map<Key, ModuleProvider> _providers = {};

  GlobalKey<NavigatorState> get key => GlobalKey<NavigatorState>( debugLabel: '$runtimeType' );

  static T of<T extends Module>(
      BuildContext context,
      {
        bool listen = true,
        bool searchDown = false,
      } ) {

    if ( searchDown == true ) {
      listen = false;
    }

    final ModuleProvider? result = () {
      if ( listen ) {
        return context.dependOnInheritedWidgetOfExactType<ModuleProvider>();
      } else if ( searchDown ) {
        return context.findLastChildElementForWidgetOfType<ModuleProvider>()?.widget as ModuleProvider?;
      } else {
        return context.findAncestorWidgetOfExactType<ModuleProvider>();
      }
    }();

    assert(result != null, 'No $T found in context');
    return result!.module as T;
  }

  static T? maybeOf<T extends Module>( BuildContext context, { bool searchDown = false, } ) {
    try {
      return of<T>( context, searchDown: searchDown );
    } catch ( e ) {
      return null;
    }
  }

  ModuleProvider? get activeProvider {
    for ( var entry in _providers.entries ) {
      BuildContext? ctx = entry.value.module.key.currentContext;

      if ( ctx != null) {
        var route = ModalRoute.of( ctx );
        if ( route?.isCurrent == true ) {
          return entry.value;
        }
      }
    }

    return null;
  }

  void registerProvider({ required Key key, required ModuleProvider provider }) {
    assert( !_providers.keys.contains( key) );
    _providers[ key ] = provider;
  }

  void disposeProvider({ required Key key }) {
    assert( _providers.keys.contains( key) );
    _providers.remove( key );
  }

  T getService<T extends Service>() {
    assert( application.componentExists<T>(), "Service of type $T was not registered with the Application" );
    return application.component<T>();
  }

  Module( {
    required this.application,
  } );

  @override
  @mustCallSuper
  init() async {
    if ( initialized ) {
      return;
    }

    await configureDependencies();

    return super.init();
  }

  Future<void> configureDependencies() async { }

  List<ContentSlice> buildSlices() => [];

  List<ContentRoute> buildRoutes() => [];

  Future onBeforePush( String routeName, BuildContext? context ) async {}

  Future onBeforePop( String routeName, BuildContext? context ) async {}

  void onDidPop( Route<dynamic> route, Route<dynamic>? previousRoute ) {}

  Future<bool> shouldPop( String routeName, BuildContext? context ) async => true;

  Future<bool> canPop() async => key.currentState?.canPop() ?? true;

  bool canHandleRoute( String? routeName ) => routes.map((e) => e.routeName).contains( routeName );

  bool checkGuard( ContentRoute request ) => ! request.guarded;

  @override
  Future<void> dispose() async {

  }

}
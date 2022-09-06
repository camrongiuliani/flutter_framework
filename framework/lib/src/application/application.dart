library meetri_core;

import 'dart:async';
import 'package:app/src/models/framework_component.dart';
import 'package:app/src/router/framework_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Router;
import 'package:logger/logger.dart';
import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:uuid/uuid.dart';
import 'package:app/framework.dart';
import 'package:app/src/bus/bus.dart';
import 'package:app/src/storage/storage.dart';
import 'package:v_widgets/v_widgets.dart';

class Application extends FrameworkComponent {

  /// Default [Application] constructor.
  Application._( this.appBus, this.typeAdapters, this._viewModel, this.storageID );

  /// Returns a singleton [_instance] of [Application]
  factory Application( { EventBus? bus, AppViewModel? viewModel, List<dynamic> typeAdapters = const [] } ) {
    return _instance ??= Application._( AppEventBus( eventBus: bus ), typeAdapters, viewModel, null );
  }

  /// Creates a non-singleton App instance (for headless).
  factory Application.headless({ required String storageID, EventBus? bus, List<dynamic> typeAdapters = const [], AppViewModel? viewModel }) {
    return Application._( AppEventBus( eventBus: bus ), typeAdapters, viewModel, storageID );
  }

  /// Returns the [Application] most closely associated with the given context.
  ///
  /// Parameters:
  ///   * [context] - The current BuildContext.
  ///   * [listen] - Whether or not to register the Application as a dependency of [context].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// Application app = Application.of(context);
  /// ```
  ///
  /// The given [BuildContext] will be rebuilt if the state of the route changes
  /// while it is visible (specifically, if [isCurrent] or [canPop] change value).
  static Application of( BuildContext context, { bool listen = true } ) {
    final AppProvider? result = () {
      if ( listen ) {
        return context.dependOnInheritedWidgetOfExactType<AppProvider>();
      } else {
        return context.findAncestorWidgetOfExactType<AppProvider>();
      }
    }();

    assert(result != null, 'No ApplicationWidget found in context');
    return result!.application;
  }

  /// Tries to call [Application.of], and returns null on error.
  static Application? maybeOf( BuildContext context, { bool listen = true } ) {
    try {
      return Application.of( context, listen: listen );
    } catch ( e ) {
      if ( kDebugMode ) {
        print( e );
      }
    }
    return null;
  }

  /// The [Application] singleton instance.
  static Application? _instance;

  final String? storageID;

  /// [Application] provided key-value storage.
  ///
  /// Contains data store
  ///
  /// See Also:
  ///   * [BaseStore],
  ///   * [KeyValueStore]
  Storage get storage => _storage ??= Storage( storageID );

  /// Single set [Storage] instance.
  Storage? _storage;

  /// [Application] [Router] singleton instance.
  ///
  /// See Also:
  ///   * [Router] - Flutter navigation wrapper,
  ///   * [key] - The single GlobalKey for the [Application] router.
  FrameworkNavigator get router => _navigator ??= FrameworkNavigator( this );

  /// Single set [Router] instance.
  FrameworkNavigator? _navigator;

  /// [AppViewModel] singleton instance.
  ///
  /// Contains Application level state (Globals).
  ///
  /// See Also:
  ///   * [Application],
  ///   * [ViewModel]
  AppViewModel get viewModel => _viewModel ??= AppViewModel();

  /// Single set [AppViewModel] instance.
  AppViewModel? _viewModel;

  /// Messaging bus for component/service/app communication.
  final AppEventBus appBus;

  final List<dynamic> typeAdapters;

  /// Stores for currently loaded and WILl be loaded components (modules/services).
  final Map<Type, FrameworkComponent> _components = {};
  final Map<Type, FrameworkComponentBuilder> _asyncComponents = {};

  List<Module> get modules => _components.values.whereType<Module>().toList();
  List<Service> get services => _components.values.whereType<Service>().toList();

  final Map<Module, List<ContentRoute>> _contentRoutes = {};
  final Map<Module, List<ContentSlice>> _slices = {};

  ModuleProvider? get activeProvider {
    return modules.lastWhereOrNull((element) => element.activeProvider != null )?.activeProvider;
  }

  final Logger logger = Logger(
    level: Level.verbose,
    printer: PrettyPrinter(),
  );

  List<ContentType> get _registeredContentRoutes => _contentRoutes.isEmpty ? [] : _contentRoutes.values.reduce((value, element) {
    return [
      ...value,
      ...element,
    ];
  }).map((e) => e.contentType).toList();

  List<ContentType> get _registeredSlices => _slices.isEmpty ? [] : _slices.values.reduce((value, element) {
    return [
      ...value,
      ...element,
    ];
  }).map((e) => e.contentType).toList();

  // Deprecate
  dynamic authenticator;
  dynamic cacheHandler;

  Stream get onEvent => appBus.stream;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.v( 'Navigator :: Pushed (${route.settings.name}) on-top of ${previousRoute?.settings.name ?? 'the underlying component'} ' );
  }


  @override
  Future<void> dispose() async {

    _asyncComponents.clear();

    for ( FrameworkComponent component in _components.values ) {
      await component.dispose();
    }

    _components.clear();

    await storage.mutable.dump( debugAllowDumpLocked: true );

  }

  @override
  init() async {
    logger.v( 'Application Init' );

    if ( initialized ) {
      return;
    }

    await storage.init( typeAdapters: typeAdapters );

    return super.init();
  }

  Widget? get appBar => viewModel.appBar.value;

  void setAppBar( { Widget? widget, bool betweenFrame = false } ) {

    void work() {
      if ( widget == null ) {
        viewModel.appBar.value = null;
      } else {
        viewModel.appBar.value = AppBarProxy(
          child: widget,
        );
      }
    }

    if ( betweenFrame ) {
      _workBetweenFrames(() async => work());
    } else {
      work();
    }
  }

  void toggleBottomSheet() {
    if ( viewModel.solidController.isOpened ) {
      viewModel.solidController.hide();
    } else {
      viewModel.solidController.show();
    }
  }

  set bottomNavigation( Widget? widget ) => viewModel.bottomNavigation.value = widget;
  Widget? get bottomNavigation => viewModel.bottomNavigation.value;

  setBottomSheet( Widget? widget, [ bool show = true ] ) {
    workBetweenFrames([
          () async => viewModel.bottomSheet.value = widget,
          () async {
        if ( show ) {
          viewModel.solidController.show();
        }
      },
    ]);
  }

  Widget? get bottomSheet => viewModel.bottomSheet.value;

  @override
  void emit( event ) => appBus.emit( event );

  Future<Object?> emitWithResponse( event, { Duration timeout = const Duration( milliseconds: 500, ) } ) => appBus.emitWithResponse( event, timeout: timeout );

  Future<String> get currentEnvironment async {

    String? domain = await storage.mutable.get<String>( storage_key_environment );

    if ( domain == null ) {
      throw Exception( 'currentDomain was accessed but read a null value' );
    }

    return domain;
  }

  T component<T extends FrameworkComponent>() {
    assert( '$T' != 'Component', 'Component type not specified.' );
    assert(_components.containsKey( T ), 'Component of type $T not registered.');
    return _components[ T ] as T;
  }

  bool componentExists<T extends FrameworkComponent>() {
    return _components.containsKey( T );
  }

  Future<String> get deviceID async {
    String? id = await storage.immutable.get( storage_key_device_id );

    if ( id == null ) {
      id = const Uuid().v4();
      storage.immutable.set( storage_key_device_id, id );
    }

    return id;
  }


  _register<T extends FrameworkComponent>( T component, { bool syncBus = true } ) {

    assert( '$T' != 'Component', 'Component type not specified or inferred.' );

    assert( () {
      return ! _components.keys.contains( T );
    }(), 'Component of type $T already registered.');

    assert( () {
      return ! _asyncComponents.keys.contains( T );
    }(), 'AsyncComponent of type $T already registered.');

    _components[T] = component;

    logger.v( 'Application Registered Component of Type $T' );

    if ( component is Module ) {

      component.slices.addAll( component.buildSlices() );
      component.routes.addAll( component.buildRoutes() );

      if ( component.slices.isNotEmpty ) {
        assert( () {
          var existing = _registeredSlices;
          var added = component.slices.map((e) => e.contentType);

          for ( ContentType type in added ) {
            if ( existing.contains( type ) ) {
              return false;
            }
          }

          return true;
        }(), 'Slice for given [ContentType] was already registered.');
        _slices[ component ] = component.slices;

        for ( var slice in component.slices ) {
          logger.v( 'Application Registered ContentSlice for ${slice.contentType}' );
        }
      }

      if ( component.routes.isNotEmpty ) {
        assert( () {
          var existing = _registeredContentRoutes;
          var added = component.routes.map((e) => e.contentType);

          for ( ContentType type in added ) {
            if ( existing.contains( type ) ) {
              return false;
            }
          }

          return true;
        }(), 'Content type was already registered. Each content type can only be handled by a single module.');

        _contentRoutes[ component ] = component.routes;

        for ( var route in component.routes ) {
          logger.v( 'Application Registered ContentRoute for ${route.contentType}' );
        }
      }
    }

    if ( syncBus ) {
      appBus.merge( component.bus );
    }
  }

  bool canRouteToContentType( ContentType contentType ) {
    try {
      routeForContentType( contentType );
      return true;
    } catch ( e ) {
      logger.v( 'Unable to route to ContentType: $contentType, ' );
    }
    return false;
  }

  ContentRoute routeForContentType( ContentType contentType ) {
    assert( _registeredContentRoutes.contains( contentType ), 'Module to handle $contentType not registered' );
    var registrationEntry = _contentRoutes.entries.firstWhere((element) => element.value.map((e) => e.contentType).contains( contentType));
    return registrationEntry.value.firstWhere((element) => element.contentType == contentType);
  }

  bool sliceExists( ContentType contentType ) {
    return _registeredSlices.contains( contentType );
  }

  Widget slice( BuildContext context, ContentType contentType, { ViewArgs? arguments } ) {
    assert( _registeredSlices.contains( contentType ), 'Module to handle slice for $contentType not registered' );
    var registrationEntry = _slices.entries.firstWhere((element) => element.value.map((e) => e.contentType).contains( contentType));
    var slice = registrationEntry.value.firstWhere((element) => element.contentType == contentType);
    return FutureBuilder(
      future: () async {
        return registrationEntry.key.init();
      }(),
      builder: ( ctx, snapshot ) => Vif(
        test: () => snapshot.connectionState == ConnectionState.done,
        ifTrue: () => ModuleProvider(
          module: registrationEntry.key,
          widget: slice.builder( arguments ),
        ),
      ),
    );
  }

  register<T extends FrameworkComponent>( T component, { bool syncBus = true } ) {
    _register<T>( component, syncBus: syncBus );
  }

  registerAsync<T extends FrameworkComponent>( FrameworkComponentBuilder<T> builder ) {
    assert( '$T' != 'Component', 'Component type not specified or inferred.' );
    assert( () {
      return ! _asyncComponents.keys.contains( T );
    }(), 'AsyncComponent of type $T already registered.');

    _asyncComponents[ T ] = builder;
  }

  Future<T> loadAsyncComponent<T extends FrameworkComponent>() async {

    if ( componentExists<T>() ) {
      return this.component<T>();
    }

    assert( _asyncComponents.keys.contains( T) );

    FrameworkComponentBuilder<T> builder = _asyncComponents[ T ] as FrameworkComponentBuilder<T>;

    T component = builder.build();

    _asyncComponents.remove( T );

    _register<T>( component, syncBus: builder.syncBus );

    return component;
  }

  Future<void> workBetweenFrames( List<FrameMutator> mutations ) async {
    for ( var mutation in mutations ) {
      await _workBetweenFrames( mutation );
    }
  }

  Future<void> _workBetweenFrames( FrameMutator mutation ) {
    return WidgetsBinding.instance.endOfFrame.then( ( _ ) => mutation() );
  }
}
typedef FrameMutator = Future<void> Function();
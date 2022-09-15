library app;

import 'dart:async';
import 'package:app/src/application/registries/component.dart';
import 'package:app/src/application/registries/route.dart';
import 'package:app/src/application/registries/slice.dart';
import 'package:app/src/application/controllers/storage_controller.dart';
import 'package:app/src/application/registries/use_case.dart';
import 'package:app/src/application/utils/frame_mixin.dart';
import 'package:app/src/application/controllers/view_controller.dart';
import 'package:app/src/models/framework_component.dart';
import 'package:app/src/router/framework_router.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:event_bus/event_bus.dart';
import 'package:uuid/uuid.dart';
import 'package:app/framework.dart';

part 'bus/bus_part.dart';

class Application extends FrameworkComponent with FrameMixin {

  /// The [Application] singleton instance.
  static Application? _instance;

  /// Initial route for App navigator
  final String? initialRoute;

  /// Type adapters for use with [_StorageController]
  final List<dynamic> typeAdapters;

  /// Logging utility
  final Logger logger;
  
  /// Registry for [FrameworkComponent] dependencies
  final ComponentRegistry _componentRegistry;

  /// Registry for enabled [ContentRoute]s
  final RouteRegistry _routeRegistry;

  /// Registry for enabled [ContentSlice]s
  final SliceRegistry _sliceRegistry;

  /// Registry for enabled [UseCase]s
  final UseCaseRegistry _useCaseRegistry;


  /// App level view controller (app bars, nav bars, bottom sheets)
  final ViewController _viewController;

  /// App level storage (mutable and immutable)
  final StorageController _storageController;

  /// Default [Application] constructor.
  Application._( this.typeAdapters, this.initialRoute, Level logLevel, String? storageID ) :
        logger = Logger(
          level: logLevel,
          printer: PrettyPrinter(),
        ),
        _storageController = StorageController( storageID ),
        _viewController = ViewController( logLevel ),
        _routeRegistry = RouteRegistry( logLevel ),
        _sliceRegistry = SliceRegistry( logLevel ),
        _useCaseRegistry = UseCaseRegistry( logLevel ),
        _componentRegistry = ComponentRegistry( logLevel );

  /// Returns a singleton [_instance] of [Application]
  factory Application( {  String? initialRoute, List<dynamic> typeAdapters = const [], Level logLevel = Level.verbose } ) {
    return _instance ??= Application._( typeAdapters, initialRoute, logLevel, null );
  }

  /// Creates a non-singleton App instance (for headless and testing).
  factory Application.headless({
    required String storageID,
    List<dynamic> typeAdapters = const [],
    String? initialRoute,
    Level logLevel = Level.verbose,
  }) {
    return Application._( typeAdapters, initialRoute, logLevel, storageID );
  }

  /// [Application] [Router] singleton instance.
  ///
  /// See Also:
  ///   * [Router] - Flutter navigation wrapper,
  ///   * [key] - The single GlobalKey for the [Application] router.
  FrameworkNavigator get router => _navigator ??= FrameworkNavigator( this );

  /// Single set [Router] instance.
  FrameworkNavigator? _navigator;

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


  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    logger.v( 'Navigator :: Pushed (${route.settings.name}) on-top of ${previousRoute?.settings.name ?? 'the underlying component'} ' );
  }

  @override
  Future<void> dispose() async {
    await _componentRegistry.flush();
    await _sliceRegistry.flush();
    await _useCaseRegistry.flush();
    await _routeRegistry.flush();
    await _storageController.flush( debugAllowImmutableFlush: true );
  }

  @override
  init() async {
    logger.v( 'Application Init' );

    if ( initialized ) {
      return;
    }

    await _storageController.init(
      typeAdapters: typeAdapters,
    );

    return super.init();
  }

  // *** Dependency Registries

  /// Registers a UseCase, associating it to the [component].
  registerUseCase( covariant UseCase useCase ) {
    _useCaseRegistry.register( useCase );
  }

  /// Registers [FrameworkComponent] of type [T].
  ///
  /// - syncBus - Sync the Component bus with the Application stream, effectively
  /// passing off events to the Application for relay.
  register<T extends FrameworkComponent>( T component, { bool syncBus = true } ) {

    if ( component is Module ) {
      _sliceRegistry.registerFor( component );
      _routeRegistry.registerFor( component );
    } else if ( component is! Service  ) {
      throw Exception('Unsupported Component Registration Attempt');
    }

    _useCaseRegistry.registerFor( component );

    if ( syncBus ) {
      _BusController().merge( component.bus );
    }

    _componentRegistry.register<T>( component );
  }

  /// Registers [FrameworkComponent] of type [T] asynchronously.
  ///
  /// The Component will not build nor initialize until [loadAsyncComponent] is called.
  ///
  registerAsync<T extends FrameworkComponent>( FrameworkComponentBuilder<T> builder ) {
    return _componentRegistry.registerAsync<T>( builder );
  }

  /// Finalizes registration for a previously registered async [FrameworkComponent]
  loadAsyncComponent<T extends FrameworkComponent>() {

    if ( _componentRegistry.exists<T>() ) {
      return _componentRegistry.get<T>();
    }

    var builder = _componentRegistry.getAsyncComponentBuilder<T>();

    register(builder.build(), syncBus: builder.syncBus );

    return component;
  }

  /// Returns a registered component of type [T].
  ///
  /// Throws assertion if [T] has not been registered.
  T component<T extends FrameworkComponent>() => _componentRegistry.get<T>();

  /// Checks to see if a component of type [T] has been registered.
  bool componentExists<T extends FrameworkComponent>() => _componentRegistry.exists<T>();

  /// Returns a list of actively registered Modules.
  List<Module> get modules => _componentRegistry.modules;

  /// Returns a list of actively registered services.
  List<Service> get services => _componentRegistry.services;

  /// Check to see if a slice exists for the given type
  bool sliceExists( String id ) => _sliceRegistry.exists( id );

  /// Returns a ContentSlice for the given [ContentType]
  ContentSlice slice( String id ) => _sliceRegistry.getSlice( id );

  bool useCaseExists( String id ) => _useCaseRegistry.exists( id );

  executeUseCase( String id, [ Map<String, dynamic>? args ] ) => _useCaseRegistry.getUseCase( id ).call( args );

  /// Returns the currently active ModuleProvider.
  ///
  /// The [ModuleWidget] is responsible for tracking the number of Providers
  /// created by the module.
  ModuleProvider? get activeProvider => _componentRegistry.activeProvider;

  /// Returns the currently active Module by first looking for the [activeProvider].
  ///
  /// The [ModuleWidget] is responsible for tracking the number of Providers
  /// created by the module.
  Module? get activeModule => activeProvider?.module;

  // *** EventBus Related

  /// Listens for events of type [T] or dynamic.
  Stream onEvent<T>() => _BusController().onEvent<T>();

  /// Relays events from the input bus out through the app bus
  StreamSubscription mergeBus<T>( EventBus bus ) => _BusController().merge<T>( bus );

  /// Fires an event from the app bus
  @override
  void emit( event ) => _BusController().emit( event );

  /// Fires an event through the app bus, awaiting a response.
  ///
  /// [timeout] - How long to wait for a response (default 500ms).
  Future<Object?> emitWithResponse( event, { Duration timeout = const Duration( milliseconds: 500, ) } ) {
    return _BusController().emitWithResponse( event, timeout: timeout );
  }

  // *** View Related

  AppViewModel get viewModel => _viewController.viewModel;

  /// Returns the current value for appVar from the view model.
  Widget? get appBar => _viewController.appBar;

  /// Updates the current appBar value in the view model.
  void setAppBar( { Widget? widget, bool betweenFrame = false } ) {
    if ( betweenFrame ) {
      workBetweenFrames([ () => _viewController.setAppBar( widget ) ]);
    } else {
      _viewController.setAppBar( widget );
    }
  }

  /// Updates the current bottomNavigation value in the view model.
  set bottomNavigation( Widget? widget ) => _viewController.bottomNavigation = widget;

  /// Returns the current bottomNavigation value from the view model.
  Widget? get bottomNavigation => _viewController.bottomNavigation;

  /// Updates the current bottomSheet value in the view model.
  ///
  /// - Optional [show] also toggles the bottomSheet value.
  ///
  /// Work is handled in-between render frames to avoid build race conditions.
  setBottomSheet( Widget? widget, [ bool show = true ] ) {
    var work = [
          () => _viewController.setBottomSheet( widget ),
    ];

    if ( show ) {
      work.add(() => _viewController.toggleBottomSheet());
    }

    workBetweenFrames( work );
  }

  /// Toggles the current state of the bottomSheet in the view model.
  void toggleBottomSheet() => _viewController.toggleBottomSheet();

}

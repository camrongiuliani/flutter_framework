// part of '../application.dart';

import 'package:app/framework.dart';
import 'package:app/src/models/framework_component.dart';
import 'package:logger/logger.dart';
import 'package:collection/collection.dart';

class ComponentRegistry {

  final Logger logger;

  ComponentRegistry([ Level logLevel = Level.error ]) : logger = Logger(
    level: Level.verbose,
    printer: PrettyPrinter(),
  );

  /// Stores for currently loaded and WILl be loaded components (modules/services).
  final Map<Type, FrameworkComponent> _components = {};
  final Map<Type, FrameworkComponentBuilder> _asyncComponents = {};

  List<Module> get modules => _components.values.whereType<Module>().toList();
  List<Service> get services => _components.values.whereType<Service>().toList();

  bool exists<T extends FrameworkComponent>() => _components.containsKey( T );
  bool existsAsync<T extends FrameworkComponent>() => _asyncComponents.containsKey( T );

  T get<T extends FrameworkComponent>() {
    assert( '$T' != 'FrameworkComponent', 'Component type not specified.' );
    assert( exists<T>(), 'Component of type $T not registered.');
    return _components[ T ] as T;
  }

  Future<void> flush() async {

    _asyncComponents.clear();

    for ( var component in _components.values ) {
      await component.dispose();
    }

    _components.clear();
  }


  register<T extends FrameworkComponent>( T component ) {

    assert( '$T' != 'FrameworkComponent', 'Component type not specified or inferred.' );
    assert( !exists<T>(), 'Component of type $T already registered.');
    assert( !existsAsync<T>(), 'AsyncComponent of type $T already registered.');

    _components[T] = component;

    logger.v( 'Application Registered Component of Type $T' );
  }

  registerAsync<T extends FrameworkComponent>( FrameworkComponentBuilder<T> builder ) {
    assert( '$T' != 'Component', 'Component type not specified or inferred.' );
    assert( !existsAsync<T>(), 'AsyncComponent of type $T already registered.');

    _asyncComponents[ T ] = builder;
  }

  FrameworkComponentBuilder<T> getAsyncComponentBuilder<T extends FrameworkComponent>() {

    assert( existsAsync<T>(), 'Async Component of type $T not registered' );

    return _asyncComponents[ T ] as FrameworkComponentBuilder<T>;
  }

  /// Returns the currently active ModuleProvider.
  ///
  /// The [ModuleWidget] is responsible for tracking the number of Providers
  /// created by the module.
  ModuleProvider? get activeProvider => modules
      .lastWhereOrNull((e) => e.activeProvider != null )
      ?.activeProvider;

  /// Returns the currently active Module by first looking for the [activeProvider].
  ///
  /// The [ModuleWidget] is responsible for tracking the number of Providers
  /// created by the module.
  Module? get activeModule => activeProvider?.module;

}
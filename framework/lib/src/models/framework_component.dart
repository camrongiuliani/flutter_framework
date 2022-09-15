import 'dart:async';
import 'package:app/framework.dart';
import 'package:app/src/models/super_navigation_observer.dart';
import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

abstract class FrameworkComponent extends SuperNavigationObserver {

  final EventBus bus;

  final GetIt injector;

  bool initialized = false;

  final List<UseCase> useCases = [];

  ValueNotifier<bool> progress = ValueNotifier( false );

  FrameworkComponent( { EventBus? customBus } )
      : bus = customBus ?? EventBus(),
        injector = GetIt.asNewInstance();

  @mustCallSuper
  FutureOr<void> init() async {
    initialized = true;
  }

  Future<void> dispose() async {}

  void emit( event ) => bus.fire( event );

  List<UseCase> buildUseCases() => [];

}

class FrameworkComponentBuilder<T extends FrameworkComponent> {

  final Type type;

  final bool syncBus;

  final FrameworkComponent Function() builderFunc;

  FrameworkComponentBuilder(this.builderFunc, { this.syncBus = true }) : type = T;

  T build() => builderFunc() as T;
}
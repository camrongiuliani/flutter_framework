import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:uuid/uuid.dart';
import 'package:app/framework.dart';

class AppEventBus {
  static AppEventBus? _instance;

  final EventBus _bus;

  Stream get stream => _bus.on();

  AppEventBus._( this._bus );

  factory AppEventBus( { EventBus? eventBus } ) {
    return _instance ??= AppEventBus._( eventBus ?? EventBus() );
  }

  merge( EventBus eventBus ) {
    eventBus.on().listen( _bus.fire );
  }

  void emit( event ) => _bus.fire( event );

  Future<dynamic> emitWithResponse( event, { Duration timeout = const Duration( milliseconds: 500, ) } ) async {

    String uuid = const Uuid().v4();

    Completer completer = Completer();

    StreamSubscription subscription = _bus.on().listen( ( event ) {
      if ( event is ResponseEvent && event.uuid == uuid ) {
        completer.complete( event.response );
      }
    });

    _bus.fire( RequestEvent( uuid, event ) );

    dynamic response;

    try {
      response = await completer.future.timeout( timeout );
    } catch ( e ) {
      response = null;
    } finally {
      subscription.cancel();
    }

    return response;

  }
}
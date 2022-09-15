part of '../application.dart';


class _BusController {

  static _BusController? instance;

  final EventBus _bus;

  _BusController._( this._bus );

  factory _BusController([ EventBus? customBus ]) {
    return instance ??= _BusController._( customBus ?? EventBus() );
  }

  Stream onEvent<T>() => _bus.on<T>();

  StreamSubscription merge<T>( EventBus eventBus ) {
    return eventBus.on<T>().listen( _bus.fire );
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
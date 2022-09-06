import 'package:app/framework.dart';

class RequestEvent {

  String uuid;

  dynamic event;

  RequestEvent(this.uuid, this.event);

  ResponseEvent response( dynamic response ) {
    return ResponseEvent( uuid, response, this );
  }
}
import 'package:uuid/uuid.dart';

class ProcessedUseCase {

  final String name;
  final String owner;
  final String uuid;

  ProcessedUseCase( this.owner, this.name, Uuid uuid ) : uuid = uuid.v4();

}
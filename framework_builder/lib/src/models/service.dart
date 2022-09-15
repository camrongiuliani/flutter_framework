import 'package:analyzer/dart/element/type.dart';
import 'package:framework_builder/src/misc/string_ext.dart';
import 'package:framework_builder/src/models/use_case.dart';
import 'package:uuid/uuid.dart';

class ProcessedService {

  final String name;
  final List<ProcessedUseCase> useCases;

  ProcessedService( this.name, this.useCases );
}
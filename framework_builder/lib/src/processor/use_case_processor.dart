import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:framework_annotations/framework_annotations.dart' as annotations;
import 'package:framework_builder/src/models/module.dart';
import 'package:framework_builder/src/models/route.dart';
import 'package:framework_builder/src/models/use_case.dart';
import 'package:framework_builder/src/processor/processor.dart';
import 'package:uuid/uuid.dart';

class UseCaseProcessor extends Processor<ProcessedUseCase> {

  final ClassElement _classElement;
  final String owner;

  UseCaseProcessor( ClassElement owner, this._classElement )
      : owner = owner.displayName;

  @override
  ProcessedUseCase process() {
    return ProcessedUseCase( owner, _classElement.displayName, Uuid() );
  }

}
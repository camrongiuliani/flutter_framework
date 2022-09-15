import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:framework_annotations/framework_annotations.dart' as annotations;
import 'package:framework_builder/src/models/service.dart';
import 'package:framework_builder/src/models/use_case.dart';
import 'package:framework_builder/src/processor/processor.dart';
import 'package:framework_builder/src/processor/use_case_processor.dart';
import 'package:framework_builder/src/type_utils.dart';
import 'package:framework_builder/src/iterable_extension.dart';

class ServiceProcessor extends Processor<ProcessedService> {

  final ClassElement _classElement;
  late final DartObject? serviceAnnotation;

  ServiceProcessor( this._classElement ) {
    serviceAnnotation = _classElement.getAnnotation( annotations.MaestroService );
  }

  @override
  ProcessedService process() {

    final useCases = _processUseCases();

    return ProcessedService( _classElement.displayName, useCases );

  }

  List<ProcessedUseCase> _processUseCases() {
    return serviceAnnotation
        ?.getField( 'useCases' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toTypeValue()?.element2)
        .whereType<ClassElement>()
        .where( _isUseCase )
        .map((e) {
          return UseCaseProcessor( _classElement, e ).process();
        })
        .toList() ?? [];
  }

  bool _isUseCase( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.MaestroUseCase ) &&
        !classElement.isAbstract;
  }

}
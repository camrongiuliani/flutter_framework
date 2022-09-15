import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:framework_annotations/framework_annotations.dart' as annotations;
import 'package:framework_builder/src/models/framework.dart';
import 'package:framework_builder/src/models/module.dart';
import 'package:framework_builder/src/models/service.dart';
import 'package:framework_builder/src/models/use_case.dart';
import 'package:framework_builder/src/processor/processor.dart';
import 'package:framework_builder/src/processor/module_processor.dart';
import 'package:framework_builder/src/processor/service_processor.dart';
import 'package:framework_builder/src/processor/use_case_processor.dart';
import 'package:framework_builder/src/type_utils.dart';
import 'package:framework_builder/src/iterable_extension.dart';


class FrameworkProcessor extends Processor<ProcessedFramework> {

  final ClassElement _frameworkElement;
  late final DartObject? _frameworkAnnotation;

  FrameworkProcessor( this._frameworkElement ) {
    _frameworkAnnotation = _getFrameworkAnnotation();
  }

  @override
  ProcessedFramework process() {

    final modules = _processModules();
    final services = _processServices();
    final useCases = _processUseCases();

    for ( var module in modules ) {
      useCases.addAll( module.useCases );
    }

    for ( var service in services ) {
      useCases.addAll( service.useCases );
    }

    return ProcessedFramework( _frameworkElement, modules, services, useCases );
  }

  DartObject? _getFrameworkAnnotation() {
    return _frameworkElement.getAnnotation( annotations.FrameworkApp );
  }

  List<ProcessedModule> _processModules() {
    return _frameworkAnnotation
        ?.getField( 'modules' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toTypeValue()?.element2)
        .whereType<ClassElement>()
        .where( _isModule )
        .map((classElement) {
          return ModuleProcessor(
            classElement,
          ).process();
        })
        .toList() ?? [];
  }

  List<ProcessedService> _processServices() {
    return _frameworkAnnotation
        ?.getField( 'services' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toTypeValue()?.element2)
        .whereType<ClassElement>()
        .where( _isService )
        .map((classElement) {
          return ServiceProcessor(
            classElement,
          ).process();
        })
        .toList() ?? [];
  }

  List<ProcessedUseCase> _processUseCases() {
    return _frameworkAnnotation
        ?.getField( 'useCases' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toTypeValue()?.element2)
        .whereType<ClassElement>()
        .where( _isUseCase )
        .map((e) {
          return UseCaseProcessor( _frameworkElement, e ).process();
        })
        .toList() ?? [];
  }

  bool _isModule( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.MaestroModule ) &&
        !classElement.isAbstract;
  }

  bool _isService( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.MaestroService ) &&
        !classElement.isAbstract;
  }

  bool _isUseCase( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.MaestroUseCase ) &&
        !classElement.isAbstract;
  }

}
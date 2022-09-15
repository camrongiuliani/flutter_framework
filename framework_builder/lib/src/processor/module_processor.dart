import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:framework_annotations/framework_annotations.dart' as annotations;
import 'package:framework_builder/src/models/module.dart';
import 'package:framework_builder/src/models/route.dart';
import 'package:framework_builder/src/models/use_case.dart';
import 'package:framework_builder/src/processor/processor.dart';
import 'package:framework_builder/src/processor/route_processor.dart';
import 'package:framework_builder/src/processor/use_case_processor.dart';
import 'package:framework_builder/src/type_utils.dart';
import 'package:framework_builder/src/iterable_extension.dart';

class ModuleProcessor extends Processor<ProcessedModule> {

  final ClassElement _classElement;
  late final DartObject? _moduleAnnotation;

  ModuleProcessor( this._classElement ) {
    _moduleAnnotation = _classElement.getAnnotation( annotations.MaestroModule );
  }

  @override
  ProcessedModule process() {

    final useCases = _processUseCases();
    final routes = _processRoutes();

    return ProcessedModule( _classElement.displayName, routes, useCases );

  }

  List<ProcessedRoute> _processRoutes() {

    final baseRoute = _moduleAnnotation
        ?.getField( 'baseRoute' )
        ?.toStringValue() ??
        _classElement.displayName;

    return _moduleAnnotation
        ?.getField( 'routes' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toTypeValue()?.element2)
        .whereType<ClassElement>()
        .where( _isRoute )
        .map((e) {
          return RouteProcessor( baseRoute, e ).process();
        })
        .toList() ?? [];
  }

  List<ProcessedUseCase> _processUseCases() {
    return _moduleAnnotation
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

  bool _isRoute( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.MaestroRoute ) &&
        !classElement.isAbstract;
  }

  bool _isUseCase( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.MaestroUseCase ) &&
        !classElement.isAbstract;
  }
}
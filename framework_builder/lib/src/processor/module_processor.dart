

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:framework_annotations/framework_annotations.dart' as annotations;
import 'package:framework_builder/src/models/Module.dart';
import 'package:framework_builder/src/processor/Processor.dart';
import 'package:framework_builder/src/type_utils.dart';

class ModuleProcessor extends Processor<ProcessedModule> {

  final ClassElement _classElement;

  ModuleProcessor(final ClassElement classElement)
      : _classElement = classElement;

  @override
  ProcessedModule process() {

    final baseRoute = _getBaseRoute();

    final childRoutes = _getChildRoutes();

    return ProcessedModule( _classElement.displayName, baseRoute, childRoutes );

  }

  String _getBaseRoute() {
    return _classElement
        .getAnnotation( annotations.FrameworkModule )
        ?.getField( 'baseRoute' )
        ?.toStringValue() ??
        _classElement.displayName;
  }

  Map<DartType, String> _getChildRoutes() {
    return _classElement
        .getAnnotation( annotations.FrameworkModule )
        ?.getField( 'childRoutes' )
        ?.toMapValue()
        ?.map<DartType, String>((key, value) => MapEntry(key!.toTypeValue()!, value!.toStringValue()!)) ?? const {};
  }

}
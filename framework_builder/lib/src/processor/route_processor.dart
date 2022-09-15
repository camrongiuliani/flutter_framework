

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:framework_annotations/framework_annotations.dart' as annotations;
import 'package:framework_builder/src/models/module.dart';
import 'package:framework_builder/src/models/route.dart';
import 'package:framework_builder/src/models/service.dart';
import 'package:framework_builder/src/processor/processor.dart';
import 'package:framework_builder/src/type_utils.dart';

class RouteProcessor extends Processor<ProcessedRoute> {

  final String baseRoute;
  final ClassElement _classElement;
  late final ProcessedRoute result;

  RouteProcessor( this.baseRoute, this._classElement );

  @override
  ProcessedRoute process() {

    final path = _getChildRoute();

    return ProcessedRoute( '/${baseRoute}/$path' );

  }

  String _getChildRoute() {
    return _classElement
        .getAnnotation( annotations.MaestroRoute )
        ?.getField( 'name' )
        ?.toStringValue() ??
        _classElement.displayName;
  }

}
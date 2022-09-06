

import 'package:analyzer/dart/element/element.dart';
import 'package:framework_annotations/framework_annotations.dart' as annotations;
import 'package:framework_builder/src/models/Framework.dart';
import 'package:framework_builder/src/processor/Processor.dart';
import 'package:framework_builder/src/processor/module_processor.dart';
import 'package:framework_builder/src/type_utils.dart';
import '../iterable_extension.dart';

import '../models/Module.dart';

class FrameworkProcessor extends Processor<ProcessedFramework> {

  final ClassElement _classElement;

  FrameworkProcessor(final ClassElement classElement)
      : _classElement = classElement;

  @override
  ProcessedFramework process() {
    final frameworkName = _classElement.displayName;

    print( 'Processing for $frameworkName' );

    final modules = _getModules( _classElement );

    return ProcessedFramework( _classElement, frameworkName, modules );
  }

  List<ProcessedModule> _getModules(
      final ClassElement frameworkClassElement,
      ) {

    final entities = _classElement
        .getAnnotation( annotations.FrameworkApp )
        ?.getField( 'modules' )
        ?.toListValue()
        ?.mapNotNull((object) => object.toTypeValue()?.element2)
        .whereType<ClassElement>()
        .where( _isModule )
        .map((classElement) => ModuleProcessor(
          classElement,
        ).process())
        .toList();

    if (entities == null || entities.isEmpty) {
      throw Exception( 'Modules cannot be empty.' );
    }

    return entities;
  }

  bool _isModule( final ClassElement classElement ) {
    return classElement.hasAnnotation( annotations.FrameworkModule ) &&
        !classElement.isAbstract;
  }


}
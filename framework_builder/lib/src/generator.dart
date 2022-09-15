import 'dart:async';
import 'package:build/build.dart';
import 'package:framework_annotations/framework_annotations.dart';
import 'package:framework_builder/src/processor/framework_processor.dart';
import 'package:source_gen/source_gen.dart' ;
import 'package:analyzer/dart/element/element.dart';
import 'models/framework.dart';

class FrameworkGenerator extends GeneratorForAnnotation<FrameworkApp> {

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: 'Remove the [FrameworkApp] annotation from `$friendlyName`.',
      );
    }

    ProcessedFramework framework = FrameworkProcessor( element ).process();

    return framework.write();

  }
}

class UseCaseGenerator extends GeneratorForAnnotation<MaestroUseCase> {

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: 'Remove the [MaestroUseCase] annotation from `$friendlyName`.',
      );
    }

    ProcessedFramework framework = FrameworkProcessor( element ).process();

    return framework.write();

  }
}
import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:framework_builder/src/models/service.dart';
import 'package:framework_builder/src/misc/string_ext.dart';
import 'package:framework_builder/src/models/use_case.dart';
import 'package:framework_builder/src/writer/access_writer.dart';
import 'package:framework_builder/src/writer/route_writer.dart';
import 'package:framework_builder/src/writer/title_writer.dart';
import 'package:framework_builder/src/writer/use_case_writer.dart';
import 'package:uuid/uuid.dart';
import 'module.dart';

class ProcessedFramework {

  final ClassElement classElement;
  final List<ProcessedModule> modules;
  final List<ProcessedService> services;
  final List<ProcessedUseCase> _useCases;

  late final String frameworkName;

  ProcessedFramework( this.classElement, this.modules, this.services, this._useCases ) {
    frameworkName = classElement.displayName;
  }

  String write() {

    LibraryBuilder builder = LibraryBuilder();

    builder..body.addAll([
      TitleWriter( 'Maestro Base' ).write(),
      AccessWriter().write(),

      TitleWriter( 'Maestro Routes' ).write(),
      RouteWriter( modules.map((e) => e.routes).reduce((value, element) => [
        ...value,
        ...element,
      ]).toList() ).write(),

      TitleWriter( 'Maestro UseCase IDs' ).write(),
      UseCaseWriter( _useCases ).write(),
    ]);

    final lib = builder.build();

    return lib.accept( DartEmitter() ).toString();
  }

  Iterable<String> get useCases => _useCases
      .map((e) => '/$frameworkName/${e.owner}')
      .map(( r ) => 'final String ${_canonicalize( r )} = \'${Uuid().v4()}\';');

  String _canonicalize( String r ) => r.replaceAll(RegExp(r'[^\w\s]+'), '_').replaceFirst('_', '').camelCase;

}
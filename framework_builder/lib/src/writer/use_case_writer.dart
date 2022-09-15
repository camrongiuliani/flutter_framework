import 'package:code_builder/code_builder.dart';
import 'package:framework_builder/src/misc/string_ext.dart';
import 'package:framework_builder/src/models/use_case.dart';
import 'package:framework_builder/src/writer/writer.dart';

class UseCaseWriter extends Writer {

  final List<ProcessedUseCase> _useCases;

  UseCaseWriter( this._useCases );

  @override
  Spec write() {
    String className = '_UseCases';

    final classBuilder = ClassBuilder();

    final constructorBuilder = ConstructorBuilder();
    constructorBuilder..constant = true;

    classBuilder..name = className;
    classBuilder..fields.addAll( _getFields() );
    classBuilder..constructors.add( constructorBuilder.build() );

    return classBuilder.build();
  }

  List<Field> _getFields() {
    return _useCases.map((e) {
      return Field( ( builder) {
        builder
          ..name = '/${e.owner}/${e.name.split('<')[0]}'.canonicalize
          ..modifier = FieldModifier.final$
          ..assignment = Code( '\'${e.uuid}\'' )
          ..type = refer('String');
      });
    }).toList();
  }
}
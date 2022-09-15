import 'package:code_builder/code_builder.dart';
import 'package:framework_builder/src/models/route.dart';
import 'package:framework_builder/src/writer/writer.dart';

class RouteWriter extends Writer {

  final List<ProcessedRoute> _routes;

  RouteWriter( this._routes );

  @override
  Spec write() {
    String className = '_Routes';

    final classBuilder = ClassBuilder();

    final constructorBuilder = ConstructorBuilder();
    constructorBuilder..constant = true;

    classBuilder..name = className;
    classBuilder..fields.addAll( _getFields() );
    classBuilder..constructors.add( constructorBuilder.build() );

    return classBuilder.build();
  }

  List<Field> _getFields() {
    return _routes.map((e) {
      return Field( ( builder) {
        builder
          ..name = e.name
          ..modifier = FieldModifier.final$
          ..assignment = Code( '\'${e.path}\'' )
          ..type = refer('String');
      });
    }).toList();
  }
}
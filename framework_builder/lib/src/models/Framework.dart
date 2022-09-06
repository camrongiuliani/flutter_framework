import 'package:analyzer/dart/element/element.dart';
import 'package:dart_style/dart_style.dart';

import 'Module.dart';

class ProcessedFramework {

  final ClassElement classElement;
  final String name;
  final List<ProcessedModule> modules;

  ProcessedFramework( this.classElement, this.name, this.modules );

  String write() {
    StringBuffer sb = StringBuffer();

    sb.writeAll( [
      'class FrameworkRoutes {',
      ...modules.map((e) => e.fields.join('\n')),
      '}'
    ], '\n' );

    return DartFormatter().format( sb.toString() );
  }
}
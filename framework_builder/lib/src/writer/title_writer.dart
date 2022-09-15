import 'package:code_builder/code_builder.dart';
import 'package:framework_builder/src/writer/writer.dart';

class TitleWriter extends Writer {

  final String title;

  TitleWriter( this.title );

  @override
  Spec write() {
    return Code( writeHeader( title ) );
  }

  String writeHeader( String header ) {
    StringBuffer sb = StringBuffer();

    sb.writeAll([
      '\n\n',
      '// ********************************',
      '// $header',
      '// ********************************',
      '\n'
    ], '\n');

    return sb.toString();
  }
}
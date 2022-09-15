import 'package:framework_builder/src/misc/string_ext.dart';

class ProcessedRoute {

  final String name;
  final String path;

  ProcessedRoute( this.path ) :
        name = path.canonicalize;
}


import 'package:analyzer/dart/element/type.dart';
import 'package:framework_builder/src/misc/string_ext.dart';

class ProcessedModule {

  final String name;
  final String baseRoute;
  final Map<DartType, String> childRoutes;

  List<String> get routes {
    List<String> _routes = [];

    for ( var r in childRoutes.entries ) {
      _routes.add( '/$baseRoute/${r.value}' );
    }

    return _routes;
  }

  Iterable<String> get fields {
    return routes.map(( r ) {
      return 'static String ${_canonicalize( r )} = \'${r}\';';
    });
  }

  String _canonicalize( String r ) => r.replaceAll(RegExp(r'[^\w\s]+'), '_').replaceFirst('_', '').camelCase;

  ProcessedModule( this.name, this.baseRoute, this.childRoutes );
}
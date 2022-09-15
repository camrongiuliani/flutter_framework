import 'package:app/framework.dart';
import 'package:logger/logger.dart';

class RouteRegistry {

  final Logger logger;

  RouteRegistry([ Level logLevel = Level.error ]) : logger = Logger(
    level: Level.verbose,
    printer: PrettyPrinter(),
  );

  final Map<Module, List<ContentRoute>> _contentRoutes = {};

  List<String> get _registeredContentRoutes => _contentRoutes.isEmpty ? [] : _contentRoutes.values.reduce((value, element) {
    return [
      ...value,
      ...element,
    ];
  }).map((e) => e.routeName).toList();


  bool exists( String routeName ) => _registeredContentRoutes.contains( routeName );

  MapEntry<Module, List<ContentRoute>> _getRegistrationEntry( String route ) {
    assert( _registeredContentRoutes.contains( route ), 'Module to handle route $route not registered' );
    return _contentRoutes.entries.firstWhere((e) => e.value.map((e) => e.routeName).contains( route ));
  }

  ContentRoute getRoute( String routeName ) {
    assert( _registeredContentRoutes.contains( routeName ), 'Module to handle route $routeName not registered' );
    var registrationEntry = _getRegistrationEntry( routeName );
    return registrationEntry.value.firstWhere( (e) => e.routeName == routeName );
  }

  registerFor( covariant Module module ) {

    List<ContentRoute> routes = module.buildRoutes();

    if ( routes.isEmpty ) {
      return;
    }

    assert( () {
      for ( String routeName in routes.map((e) => e.routeName) ) {
        if ( exists( routeName ) || module.routes.map( (e) => e.routeName ).contains( routeName ) ) {
          return false;
        }
      }
      return true;
    }(), 'Route for given [ContentType] was already registered.');

    module.routes.addAll( routes );

    _contentRoutes[ module ] = module.routes;

    for ( var route in module.routes ) {
      logger.v( 'Application Registered ContentRoute for ${route.routeName}' );
    }
  }

  Future<void> flush() async {
    _contentRoutes.clear();
  }
}
import 'package:app/framework.dart';
import 'package:app/src/models/framework_component.dart';
import 'package:logger/logger.dart';

class UseCaseRegistry {

  final Logger logger;

  UseCaseRegistry([ Level logLevel = Level.error ]) : logger = Logger(
    level: Level.verbose,
    printer: PrettyPrinter(),
  );

  final Map<FrameworkComponent, List<UseCase>> _useCases = {};

  List<String> get _registeredUseCases => _useCases.isEmpty ? [] : _useCases.values.reduce((value, element) {
    return [
      ...value,
      ...element,
    ];
  }).map<String>((e) => e.id).toList();


  bool exists( String id ) => _registeredUseCases.contains( id );

  MapEntry<FrameworkComponent, List<UseCase>> _getRegistrationEntry( String id ) {
    assert( _registeredUseCases.contains( id ), 'Component to handle UseCase $id not registered' );
    return _useCases.entries.firstWhere((e) => e.value.map((e) => e.id).contains( id ));
  }

  UseCase getUseCase( String id ) {
    assert( _registeredUseCases.contains( id ), 'Component to handle UseCase $id not registered' );
    var registrationEntry = _getRegistrationEntry( id );
    return registrationEntry.value.firstWhere( (e) => e.id == id );
  }

  register( UseCase uc ) {
    assert( () {
      if ( exists( uc.id ) || uc.owner.useCases.map( (e) => e.id ).contains( uc.id ) ) {
        return false;
      }
      return true;
    }(), 'UseCase ${uc.id} was already registered.');

    uc.owner.useCases.add( uc );

    if ( _useCases.containsKey( uc.owner ) ) {
      _useCases[ uc.owner ]?.add( uc );
    } else {
      _useCases[ uc.owner ] = [ uc ];
    }

    logger.v( '[${uc.owner.runtimeType}] Registered UseCase under id: ${uc.id}' );
  }

  registerFor( covariant FrameworkComponent component ) {

    List<UseCase> useCases = component.buildUseCases();

    if ( useCases.isEmpty ) {
      return;
    }

    for ( var uc in useCases ) {
      register( uc );
    }

  }

  Future<void> flush() async {
    _useCases.clear();
  }
}
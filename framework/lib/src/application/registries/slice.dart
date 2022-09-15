import 'package:app/framework.dart';
import 'package:logger/logger.dart';

class SliceRegistry {

  final Logger logger;

  SliceRegistry([ Level logLevel = Level.error ]) : logger = Logger(
    level: Level.verbose,
    printer: PrettyPrinter(),
  );

  final Map<Module, List<ContentSlice>> _slices = {};

  List<String> get _registeredSlices => _slices.isEmpty ? [] : _slices.values.reduce((value, element) {
    return [
      ...value,
      ...element,
    ];
  }).map((e) => e.id).toList();

  bool exists( String id ) => _registeredSlices.contains( id );

  MapEntry<Module, List<ContentSlice>> _getRegistrationEntry( String id ) {
    assert( _registeredSlices.contains( id ), 'Module to handle slice for id $id not registered' );
    return _slices.entries.firstWhere((element) => element.value.map( (e) => e.id ).contains( id ));
  }

  ContentSlice getSlice( String id ) {
    assert( _registeredSlices.contains( id ), 'Module to handle slice for id $id not registered' );
    var registrationEntry = _getRegistrationEntry( id );
    return registrationEntry.value.firstWhere((element) => element.id == id);
  }

  registerFor( covariant Module module ) {

    List<ContentSlice> slices = module.buildSlices();

    if ( slices.isEmpty ) {
      return;
    }

    assert( () {
      for ( String id in slices.map((e) => e.id) ) {
        if ( exists( id ) || module.slices.map((e) => e.id).contains( id ) ) {
          return false;
        }
      }
      return true;
    }(), 'Slice for given [ContentType] was already registered.');

    module.slices.addAll(slices );

    _slices[ module ] = module.slices;

    for ( var slice in module.slices ) {
      logger.v( 'Application Registered ContentSlice for ${slice.id}' );
    }

  }

  Future<void> flush() async {
    _slices.clear();
  }
}
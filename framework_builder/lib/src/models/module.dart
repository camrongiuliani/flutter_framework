import 'package:framework_builder/src/models/route.dart';
import 'package:framework_builder/src/models/use_case.dart';

class ProcessedModule {

  final String name;
  final List<ProcessedRoute> _routes;
  final List<ProcessedUseCase> _useCases;

  List<ProcessedRoute> get routes => _routes;
  List<ProcessedUseCase> get useCases => _useCases;

  ProcessedModule( this.name, this._routes, this._useCases );
}
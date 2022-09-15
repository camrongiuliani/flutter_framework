
import 'package:meta/meta.dart';

@immutable
class MaestroModule {

  final String baseRoute;
  final List<String> childRoutes;
  final List<Type> routes;

  final List<Type> useCases;

  /// {@macro PublicRoute}
  const MaestroModule({  required this.baseRoute,  this.routes = const [], this.childRoutes = const [], this.useCases = const [] });
}

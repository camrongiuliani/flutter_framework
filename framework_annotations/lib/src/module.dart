
import 'package:meta/meta.dart';

@immutable
class FrameworkModule {

  final String baseRoute;
  final Map<Type, String> childRoutes;

  /// {@macro PublicRoute}
  const FrameworkModule({  required this.baseRoute, this.childRoutes = const {} });
}

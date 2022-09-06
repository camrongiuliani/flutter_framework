
import 'package:meta/meta.dart';

@immutable
class FrameworkApp {

  final List<Type> modules;

  /// {@macro PublicRoute}
  const FrameworkApp({ this.modules = const [] });
}

/// The annotation for a class to generate route definitions
const frameworkApp = FrameworkApp();
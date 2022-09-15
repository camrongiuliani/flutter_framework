
import 'package:meta/meta.dart';

@immutable
class FrameworkApp {

  final List<Type> modules;
  final List<Type> services;
  final List<Type> useCases;

  /// {@macro PublicRoute}
  const FrameworkApp({ this.modules = const [], this.services = const [], this.useCases = const [] });
}

/// The annotation for a class to generate route definitions
const frameworkApp = FrameworkApp();
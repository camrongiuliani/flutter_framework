
import 'package:meta/meta.dart';

@immutable
class MaestroService {

  final List<Type> useCases;

  /// {@macro PublicRoute}
  const MaestroService({ this.useCases = const [] });
}

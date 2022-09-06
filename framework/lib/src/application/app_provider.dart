import 'package:flutter/widgets.dart' hide Router;
import 'package:app/framework.dart';

/// Provides the Application instance to all widgets below the root widget
///
/// See also:
///
///  * [Application]
///  * [InheritedWidget]
///  * [InheritedNotifier]
///
class AppProvider extends InheritedWidget {

  final Application application;
  final AppViewModel viewModel;

  const AppProvider( {
    required this.application,
    required this.viewModel,
    required super.child,
    super.key,
  } );

  @override
  bool updateShouldNotify(covariant AppProvider oldWidget) {
    return false;
  }
}

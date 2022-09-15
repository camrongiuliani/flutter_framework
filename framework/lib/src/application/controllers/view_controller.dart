import 'package:flutter/widgets.dart';
import 'package:app/framework.dart';
import 'package:logger/logger.dart';

class ViewController {

  final Logger logger;

  ViewController([ Level logLevel = Level.error ]) : logger = Logger(
    level: Level.verbose,
    printer: PrettyPrinter(),
  );

  /// [AppViewModel] singleton instance.
  ///
  /// Contains Application level state (Globals).
  ///
  /// See Also:
  ///   * [Application],
  ///   * [ViewModel]
  AppViewModel get viewModel => _viewModel ??= AppViewModel();

  /// Single set [AppViewModel] instance.
  AppViewModel? _viewModel;

  /// Gets the current [appBar] value.
  Widget? get appBar => viewModel.appBar.value;

  void setAppBar( Widget? widget ) {
    if ( widget == null ) {
      viewModel.appBar.value = null;
    } else {
      viewModel.appBar.value = AppBarProxy(
        child: widget,
      );
    }
  }

  /// Toggles bottom sheet visibility
  void toggleBottomSheet() {
    if ( viewModel.solidController.isOpened ) {
      viewModel.solidController.hide();
    } else {
      viewModel.solidController.show();
    }
  }

  /// Get the bottom sheet
  Widget? get bottomSheet => viewModel.bottomSheet.value;

  setBottomSheet( Widget? widget ) => viewModel.bottomSheet.value = widget;


  /// Set the bottom navigation
  set bottomNavigation( Widget? widget ) => viewModel.bottomNavigation.value = widget;

  /// Get the bottom navigation
  Widget? get bottomNavigation => viewModel.bottomNavigation.value;

}
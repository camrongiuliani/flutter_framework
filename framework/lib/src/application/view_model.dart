

import 'package:bvvm/bvvm.dart';
import 'package:flutter/material.dart';
import 'package:app/framework.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class AppViewModel extends ViewModel<App> {

  final ValueNotifier<Color> statusBarColor;

  final ValueNotifier<Brightness> statusBarIconBrightness;
  final ValueNotifier<Brightness> statusBarBrightness;
  final ValueNotifier<bool> debugShowCheckedModeBanner;
  final ValueNotifier<AppBarProxy?> appBar;
  final ValueNotifier<Widget?> bottomSheet;
  final ValueNotifier<Widget?> bottomNavigation;

  final ValueNotifier<bool> extendBodyBehindAppBar;

  final SolidController solidController = SolidController();

  AppViewModel({
    Color statusBarColor = Colors.transparent,
    Brightness statusBarIconBrightness = Brightness.light,
    Brightness statusBarBrightness = Brightness.dark,
    bool debugShowCheckedModeBanner = false,
    bool extendBodyBehindAppBar = true,
    AppBarProxy? appBar,
    Widget? bottomSheet,
    Widget? bottomNavigation
  }) :
        statusBarColor = ValueNotifier( statusBarColor ),
        statusBarIconBrightness = ValueNotifier( statusBarIconBrightness ),
        statusBarBrightness = ValueNotifier( statusBarBrightness ),
        debugShowCheckedModeBanner = ValueNotifier( debugShowCheckedModeBanner ),
        appBar = ValueNotifier( appBar ),
        extendBodyBehindAppBar = ValueNotifier( extendBodyBehindAppBar ),
        bottomSheet = ValueNotifier( bottomSheet ),
        bottomNavigation = ValueNotifier( bottomNavigation );

}


import 'package:flutter/widgets.dart';

abstract class SuperNavigationObserver extends NavigatorObserver {

  Future willPop() async { }

  Future willPush( String route ) async {}

}
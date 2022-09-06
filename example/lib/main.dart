import 'package:app/framework.dart';
import 'package:flutter/material.dart';
import 'package:framework_example/framework_example.dart';
import 'package:framework_example/framework_example.routes.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  Application application = await ExampleFramework().init();

  runApp( App.create(
    application: application,
    initialRoute: FrameworkRoutes.onboardingStoreFront,
  ) );

}
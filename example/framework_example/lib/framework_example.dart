library framework_example;

import 'dart:async';

import 'package:app/framework.dart';
import 'package:framework_annotations/framework_annotations.dart';
import 'package:onboarding_module/module.dart';

@FrameworkApp(
  modules: [
    OnboardingModule,
  ]
)
class ExampleFramework {

  static ExampleFramework? instance;

  ExampleFramework._();

  factory ExampleFramework() {
    return instance ??= ExampleFramework._();
  }

  FutureOr<Application> init() async {
    Application application = Application();

    application.register<OnboardingModule>( OnboardingModule(application) );

    await application.init();

    return application;
  }

}

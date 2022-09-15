library onboarding_module;

import 'package:app/framework.dart';
import 'package:bvvm/bvvm.dart';
import 'package:framework_annotations/framework_annotations.dart';
import 'package:framework_example/framework_example.routes.dart';
import 'package:onboarding_module/ui/pages/store_front/bloc.dart';
import 'package:onboarding_module/ui/pages/store_front/page.dart';
import 'package:onboarding_module/ui/pages/store_front/view_model.dart';

@MaestroModule(
  baseRoute: OnboardingModule.route,
  childRoutes: [
    StoreFrontPage.route,
  ],
)
class OnboardingModule extends Module {

  static const String route = "onboarding";

  static OnboardingModule? instance;

  OnboardingModule._( Application application ) : super(
    application: application,
  );

  factory OnboardingModule( [ Application? application ] ) {
    assert( instance != null || application != null );
    return instance ??= OnboardingModule._( application! );
  }

  @override
  Future configureDependencies() async {
    // if ( ! application.componentExists<OnboardingService>() ) {
    //   OnboardingService s = OnboardingService( application );
    //   await s.init();
    //   application.register<OnboardingService>( s );
    // }
  }

  @override
  List<ContentRoute> buildRoutes() {
    return [
      ContentRoute(
        owner: this,
        routeName: Maestro.routes.onboardingStoreFront,
        builder: ([ args ]) {

          StoreFrontViewModel vm = StoreFrontViewModel();

          return BVVMProvider(
            bloc: StoreFrontBloc( vm ),
            view: const StoreFrontPage(),
            viewModel: vm,
          );
        }
      ),
    ];
  }

}
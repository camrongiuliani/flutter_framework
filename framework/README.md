
## Overview
This Framework aims to provide an app with a modular design approach that conforms to the SOLID principles.

The Framework is comprised of Components.

The main Component is the Application class.


## Application

The Application is a singleton that is used to register and maintain dependencies, as well as other Components.

Application has built-in storage (mutable and immutable) and will have SecureStorage implemented near-term.

Modules and Services (other types of Components) are registered for use by the Application:
```dart
Application application = Application();
application.register<OnboardingModule>( OnboardingModule( application ) );
```

You can also register async:
```dart
Application application = Application();
application.registerAsync( FrameworkComponentBuilder( () => OnboardingModule( application ) ) );
application.loadAsyncComponent<OnboardingModule>();
```

You can also register async:
```dart
Application application = Application();
application.registerAsync( FrameworkComponentBuilder( () => OnboardingModule( application ) ) );
application.loadAsyncComponent<OnboardingModule>();
```

To retrieve a Component after registration:
```dart
application.component<OnboardingModule>();
```

To check if a Component is registered:
```dart
application.componentExists<OnboardingModule>();
```

## Modules

The Module class has access to the Application, but no other module. Modules should not be direct dependencies of each other.

It is comprised of UI elements such as ContentRoutes and Slices.

The UI elements are optionally exposed to the Application class, but no other module.

A ContentRoute is a navigation route.

A Slice is a widget (or a UI 'slice' provided by this Module).

Each route and slice conforms to the BVVM pattern, in which each widget has a BLoC (for business logic) and a view model.

The widget watches the view model and notifies the BLoC on state/interaction change.

The BLoC updates the view model, updating the UI reactively.

The BLoC retrieves its data from Services, thus Modules are allowed to depend on services. See the configureDependencies() callback in the Module class.

## Services
The Service class has access to the Application, but no other service.

Services connect remote and local data.

Data sources are implemented abstractly through the use of the canonical protocol pattern (known as 'proto' in code).

There is a remote data proto and a local data proto.

Modules can depend on Services but Services should not depend on each other (whenever possible to ensure single responsibility).

## Routing
The Application coordinates intra-module and inter-module routing.

All modules use a shared router that is instantiated inside of the Application class.

When pushing a route, the Application will check each module, looking for one that is able to handle the given route.

If none is found, it should show 404.

If a module is found, then the Application will check to see if the module has an active navigator (top-layer).

If there is an active navigator, then we push on top of that.

If there is not, then we create one and then push on top of it.
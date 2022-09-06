import 'package:flutter/material.dart' hide Router;
import 'package:flutter/services.dart';
import 'package:app/framework.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:synchronized/extension.dart';
import 'package:v_widgets/v_widgets.dart';

class App extends StatefulWidget {

  final Application application;
  final String initialRoute;
  final RouteFactory? onUnknownRoute;
  final Function( dynamic )? onEvent;

  /// The wrapper for our entire app, which instantiates the main Navigator. <br><br>
  /// Note: Using [MaterialApp] anywhere else in-app may break navigation.
  ///
  const App._({
    required this.application,
    required this.initialRoute,
    this.onUnknownRoute,
    this.onEvent,
    super.key,
  });

  static Widget create({
    required Application application,
    required String initialRoute,
    onUnknownRoute,
    onEvent,
    key,
  }) {

    return AppProvider(
      application: application,
      viewModel: application.viewModel,
      child: App._(
        application: application,
        initialRoute: initialRoute,
        onUnknownRoute: onUnknownRoute,
        onEvent: onEvent,
        key: key,
      ),
    );
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  Listenable? systemChromeListenable;
  void Function()? listenerFunc;

  @override
  void initState() {

    AppViewModel vm = Application.of( context, listen: false ).viewModel;

    systemChromeListenable = Listenable.merge([
      vm.statusBarColor,
      vm.statusBarIconBrightness,
      vm.statusBarBrightness,
    ]);

    listenerFunc = () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: vm.statusBarColor.value,
        statusBarIconBrightness: vm.statusBarIconBrightness.value,
        statusBarBrightness: vm.statusBarBrightness.value,
      ));
    };

    systemChromeListenable!.addListener( listenerFunc! );

    // TODO: Make sure this doesn't leak
    if ( widget.onEvent != null ) {
      widget.application.onEvent.listen((event) {
        synchronized(() => widget.onEvent!( event) );
      });
    }

    super.initState();
  }


  @override
  void dispose() {
    if ( listenerFunc != null ) {
      systemChromeListenable?.removeListener( listenerFunc! );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    AppViewModel vm = Application.of( context ).viewModel;

    return MaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: vm.debugShowCheckedModeBanner.value,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: SafeArea(
        child: AnimatedBuilder(
            animation: Listenable.merge([
              vm.appBar,
              vm.extendBodyBehindAppBar,
            ]),
            builder: ( ctx, _ ) {
              return Scaffold(
                extendBodyBehindAppBar: vm.extendBodyBehindAppBar.value,
                appBar: () {
                  if ( vm.appBar.value == null ) {
                    return null;
                  }

                  return vm.appBar.value!;
                }(),
                bottomNavigationBar: ValueListenableBuilder<Widget?>(
                  valueListenable: vm.bottomNavigation,
                  builder: ( ctx, wgt, _ ) => Vif(
                    test: () => wgt != null,
                    ifTrue: () => wgt!,
                  ),
                ),
                body: Stack(
                  children: [
                    WillPopScope(
                      onWillPop: () async {
                        return widget.application.router.shouldPop( context );
                      },
                      child: Navigator(
                        key: widget.application.router.key,
                        initialRoute: widget.initialRoute,
                        observers: [
                          widget.application,
                        ],
                        onUnknownRoute: widget.onUnknownRoute,
                        onGenerateRoute: widget.application.router.generateRoute,
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ValueListenableBuilder<Widget?>(
                        valueListenable: vm.bottomSheet,
                        builder: ( ctx, wgt, _ ) => Vif(
                          test: () => wgt != null,
                          ifTrue: () => ValueListenableBuilder<bool>(
                            valueListenable: vm.solidController,
                            builder: ( ctx, val, _) {
                              return SolidBottomSheet(
                                controller: vm.solidController,
                                headerBar: const SizedBox.square( dimension: 0.0, ),
                                showOnAppear: val,
                                body: SizedBox(
                                  height: 300.0,
                                  child: wgt!,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
        ),
      ),
    );
  }
}

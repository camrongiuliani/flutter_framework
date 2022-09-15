import 'package:flutter/material.dart' hide Router;
import 'package:app/framework.dart';

class ModuleWidget extends StatefulWidget {

  final Module module;
  final String initialRoute;

  const ModuleWidget({
    required this.module,
    required this.initialRoute,
    required super.key,
  });

  @override
  State<ModuleWidget> createState() => _ModuleWidgetState();
}

class _ModuleWidgetState extends State<ModuleWidget> {

  @override
  void initState() {
    super.initState();
    widget.module.registerProvider(
      key: widget.key!,
      provider: context.findAncestorWidgetOfExactType<ModuleProvider>()!,
    );
  }

  @override
  void dispose() {
    widget.module.disposeProvider( key: widget.key! );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: () async {
        return widget.module.init();
      }(),
      builder: ( ctx, snapshot ) => Vif(
        test: () => snapshot.connectionState == ConnectionState.done,
        ifTrue: () => Navigator(
          key: widget.module.key,
          initialRoute: widget.initialRoute,
          observers: [
            widget.module,
          ],
          onGenerateRoute: widget.module.application.router.generateRoute,
        ),
      ),
    );
  }
}

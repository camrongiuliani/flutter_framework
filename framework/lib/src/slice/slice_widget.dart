import 'package:app/framework.dart';
import 'package:flutter/widgets.dart';
class Slice extends StatelessWidget {

  final String sliceID;
  final Widget fallback;
  final ViewArgs? arguments;

  const Slice({
    required this.sliceID,
    this.fallback = const SizedBox.square( dimension: 0.0 ),
    this.arguments,
    super.key,
  });

  @override
  Widget build( BuildContext context ) {

    Application application = Application.of( context );

    return Vif(
      test: () => application.sliceExists( sliceID ),
      ifFalse: () => fallback,
      ifTrue: () {

        ContentSlice slice = application.slice( sliceID );

        return FutureBuilder(
          future: () async {
            return slice.owner.init();
          }(),
          builder: ( ctx, snapshot ) => Vif(
            test: () => snapshot.connectionState == ConnectionState.done,
            ifTrue: () => ModuleProvider(
              module: slice.owner,
              widget: slice.buildContent( arguments ),
            ),
          ),
        );
      },
    );
  }
}
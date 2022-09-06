import 'package:flutter/material.dart' hide Router;

class AppBarProxy extends StatefulWidget implements PreferredSizeWidget {

  final Widget child;

  const AppBarProxy._( { required this.child, super.key } );

  factory AppBarProxy({ required Widget child }) {
    return AppBarProxy._(
      key: GlobalKey<State<AppBarProxy>>(),
      child: child,
    );
  }

  static AppBarProxy of( BuildContext context ) {
    final AppBarProxy? result = context.findAncestorWidgetOfExactType<AppBarProxy>();
    assert(result != null, 'No AppBarProxy found in context');
    return result!;
  }

  static AppBarProxy? maybeOf( BuildContext context ) {
    try {
      return of( context );
    } catch ( e ) {
      return null;
    }
  }

  @override
  State<AppBarProxy> createState() => _AppBarProxyState();

  @override
  Size get preferredSize => const Size.fromHeight( kToolbarHeight );
}


class _AppBarProxyState extends State<AppBarProxy> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'package:app/framework.dart';
import 'package:flutter/widgets.dart';

class ContentRoute extends Content {
  final String routeName;
  final bool guarded;

  final WidgetArgumentBuilder builder;

  const ContentRoute({
    required this.routeName,
    required Module owner,
    required this.builder,
    this.guarded = false,
  }) : super(
    owner: owner,
  );

  ContentRoute copyWith({ String? routeName, WidgetArgumentBuilder? builder}) => ContentRoute(
    routeName: routeName ?? this.routeName,
    builder: builder ?? this.builder,
    owner: owner,
  );

  @override
  Widget buildContent([ViewArgs? args]) => buildContent( args );

}
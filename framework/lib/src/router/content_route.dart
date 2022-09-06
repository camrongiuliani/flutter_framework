import 'package:app/src/content/content.dart';

class ContentRoute extends Content {
  final String routeName;

  const ContentRoute({ required super.contentType, required super.builder, required this.routeName, });

  ContentRoute copyWith({ String? routeName, WidgetArgumentBuilder? builder}) => ContentRoute(
    contentType: contentType,
    routeName: routeName ?? this.routeName,
    builder: builder ?? this.builder,
  );
}
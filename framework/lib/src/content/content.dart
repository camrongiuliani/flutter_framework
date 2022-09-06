import 'package:flutter/widgets.dart';
import 'package:app/src/models/view_arguments.dart';
import 'package:app/src/content/content_type.dart';

typedef WidgetArgumentBuilder = Widget Function([ViewArgs? args]);

abstract class Content {
  final ContentType contentType;
  final WidgetArgumentBuilder builder;

  const Content({ required this.contentType, required this.builder, });
}

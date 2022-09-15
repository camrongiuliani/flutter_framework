import 'package:app/framework.dart';
import 'package:flutter/widgets.dart';

typedef WidgetArgumentBuilder = Widget Function([ViewArgs? args]);

abstract class Content {
  final Module owner;

  const Content({ required this.owner });

  Widget buildContent([ ViewArgs? args ]);
}

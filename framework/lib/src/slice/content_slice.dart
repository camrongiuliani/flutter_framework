import 'package:app/src/content/content.dart';
import 'package:app/src/content/content_type.dart';

abstract class ContentSlice extends Content {

  String get id;

  const ContentSlice({ required super.owner });

}
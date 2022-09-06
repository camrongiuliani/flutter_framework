import 'package:app/src/content/content.dart';
import 'package:app/src/content/content_type.dart';

class ContentSlice extends Content {

  const ContentSlice({ required super.contentType, required super.builder, });

  ContentSlice copyWith({ ContentType? contentType, WidgetArgumentBuilder? builder}) => ContentSlice(
    contentType: contentType ?? this.contentType,
    builder: builder ?? this.builder,
  );
}
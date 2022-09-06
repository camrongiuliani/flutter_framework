
enum ContentType {
  deprecate('deprecate');

  const ContentType( this.value );
  final String value;

  static ContentType fromString( String val ) {
    return ContentType.values.firstWhere( ( type ) => type.name.toLowerCase() == val.toLowerCase() );
  }

  static String asString( ContentType contentType ) => contentType.name;

}
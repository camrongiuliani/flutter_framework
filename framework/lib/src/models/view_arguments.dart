enum Arg {
  userId('userId'),
  fit('fit'),
  shape('shape'),
  color('color'),
  colorAlt('colorAlt'),
  padding('padding');

  const Arg( this.value );
  final String value;

  static Arg fromString( String val ) {
    return Arg.values.firstWhere( ( arg ) => arg.name.toLowerCase() == val.toLowerCase() );
  }

  static String asString( Arg arg ) => arg.name;

}

class ViewArgs {

  final Map<Arg, dynamic> args ;

  const ViewArgs(this.args);

  bool contains( Arg arg ) => args.containsKey( arg );

  dynamic operator []( Arg arg ) => args[ arg ];
}
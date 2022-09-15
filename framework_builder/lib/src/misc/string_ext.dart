extension StringExtension on String {

  /// Capitalize the first character in a [String]
  String get capitalized {
    try {
      return "${this[0].toUpperCase()}${ substring(1) }";
    } catch (e) {
      return this;
    }
  }

  /// Converts a [String] into camel case using regex.
  String get camelCase {
    String s = replaceAllMapped(
        RegExp(
            r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
            (Match m) =>
        "${m[0]?[0].toUpperCase()}${m[0]?.substring(1).toLowerCase()}")
        .replaceAll(RegExp(r'(_|-|\s)+'), '');

    return s[0].toLowerCase() + s.substring(1);
  }

  String get canonicalize => this.replaceAll(RegExp(r'[^\w\s]+'), '_').replaceFirst('_', '').camelCase;

  bool get isUrl => startsWith( 'http' ) && Uri.tryParse( this )?.isAbsolute == true;
}
/// An annotation used to specify the class to generate code for.
class Envied {
  /// The file path relative to the project base path, which
  /// will be used to get environment variables from.
  ///
  /// If `null` or an empty [String], `.env` is used.
  final String path;

  /// TODO
  final bool useConstantNameStyle;

  const Envied({String? path, bool? useConstantNameStyle})
      : path = path ?? '.env',
        useConstantNameStyle = useConstantNameStyle ?? true;
}

/// TODO
class EnviedField {
  /// TODO
  final String? envName;

  const EnviedField({this.envName});
}

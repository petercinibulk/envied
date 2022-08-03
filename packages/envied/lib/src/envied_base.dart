/// Annotation used to specify the class to contain environment variables that will be generated from a `.env` file.
class Envied {
  /// The file path of the `.env` file, relative to the project root, which
  /// will be used to generate environment variables.
  ///
  /// If `null` or an empty [String], `.env` is used.
  final String path;

  /// Whether to require a env file exists, or else the build_runner will fail if the file does not exits
  final bool requireEnvFile;

  final String? name;

  const Envied({String? path, bool? requireEnvFile, this.name})
      : path = path ?? '.env',
        requireEnvFile = requireEnvFile ?? false;
}

/// Annotation used to specify an environment variable that should be generated from the `.env` file specified in the [Envied] path parameter.
class EnviedField {
  /// The environment variable name specified in the `.env` file to generate for the annotated variable
  final String? varName;

  const EnviedField({this.varName});
}

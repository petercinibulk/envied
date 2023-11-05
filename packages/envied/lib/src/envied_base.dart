/// Annotation used to specify the class to contain environment variables that will be generated from a `.env` file.
final class Envied {
  /// The file path of the `.env` file, relative to the project root, which
  /// will be used to generate environment variables.
  ///
  /// If `null` or an empty [String], `.env` is used.
  final String path;

  /// Whether to require a env file exists, or else the build_runner will fail if the file does not exits
  final bool requireEnvFile;

  /// The value to use as name for the generated class, with
  /// an underscore `_` prefixed.
  ///
  /// If `null` or an empty [String], the name of the annotated class is used.
  ///
  /// For example, the generated code for
  ///
  /// ```dart
  /// @Envied(name: 'Foo')
  /// abstract class Env {}
  /// ```
  ///
  /// will look like
  ///
  /// ```dart
  /// abstract class _Foo {}
  /// ```
  final String? name;

  /// Allows all the values to be encrypted using a random
  /// generated key that is then XOR'd with the encrypted
  /// value when being accessed the first time.
  /// Please note that the values can not be offered with
  /// the `const` qualifier, but only with `final`.
  /// **Can be overridden by the per-field obfuscate option!**
  final bool obfuscate;

  /// Allows all the values to be optional when the type is nullable.
  ///
  /// With this enabled, the generator will not throw an exception
  /// if the environment variable is missing and a default value was
  /// not set.
  final bool allowOptionalFields;

  const Envied({
    String? path,
    bool? requireEnvFile,
    this.name,
    this.obfuscate = false,
    this.allowOptionalFields = false,
  })  : path = path ?? '.env',
        requireEnvFile = requireEnvFile ?? false;
}

/// Annotation used to specify an environment variable that should be generated from the `.env` file specified in the [Envied] path parameter.
final class EnviedField {
  /// The environment variable name specified in the `.env` file to generate for the annotated variable
  final String? varName;

  /// Allows this values to be encrypted using a random
  /// generated key that is then XOR'd with the encrypted
  /// value when being accessed the first time.
  /// Please note that the values can not be offered with
  /// the `const` qualifier, but only with `final`.
  /// **Overrides the per-class obfuscate option!**
  final bool? obfuscate;

  /// Allows this default value to be used if the environment variable is not set.
  /// The default value to use if the environment variable
  /// is not specified in the `.env` file.
  /// The default value not to use if the environment variable
  /// is specified in the `.env` file.
  /// The default value must be a [String], [bool] or a [num].
  final Object? defaultValue;

  /// Allows this field to be optional when the type is nullable.
  ///
  /// With this enabled, the generator will not throw an exception
  /// if the environment variable is missing and a default value was
  /// not set.
  final bool? optional;

  const EnviedField({
    this.varName,
    this.obfuscate,
    this.defaultValue,
    this.optional,
  });
}

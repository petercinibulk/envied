/// Annotation with default options
const envied = Envied();

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

  /// Whether to convert field names from camelCase to CONSTANT_CASE when
  /// the @EnvField annotation is not explicitly assigned a varName.
  ///
  /// By default, this is set to `false`, which means field names will
  /// retain their original camelCase format unless varName is specified. f
  ///
  /// When set to `true`, field names will be automatically transformed into
  /// CONSTANT_CASE when no specific varName is provided in or no specifics
  /// useConstantCase value set to the @EnvField annotation. This follows
  /// the Effective Dart naming conventions where  variables and field names
  /// start with lowercase letters and use uppercase  for the first letter of
  /// each subsequent word.
  ///
  /// Example:
  /// ```dart
  /// @Envied(useUpperSnakeCase: true)
  /// class MyEnvironment {
  ///   @EnvField()
  ///   String apiKey; // Transformed to 'API_KEY'
  ///
  ///   @EnvField(varName: 'MY_TOKEN')
  ///   String token; // Specified varName retains original format
  /// }
  /// ```
  final bool useConstantCase;

  /// Whether to read the ultimate values from [Platform.environment] rather
  /// than from the `.env` file.  When set to true, the value found in the
  /// `.env` file will not be used as the ultimate value but will instead be
  /// used as the key and the ultimate value will be read from
  /// [Platform.environment].
  final bool environment;

  /// Whether to interpolate the values for all fields.
  /// If [interpolate] is `true`, the value will be interpolated
  /// with the environment variables.
  final bool interpolate;

  /// Whether to use the raw string format for all string values.
  ///
  /// **NOTE**: The string is always formatted `'<value>'`.
  ///
  /// If [rawStrings] is `true`, all Strings will be raw formatted `r'<value>'`
  /// and the value may not contain a single quote.
  /// Escapes single quotes and newlines in the value.
  final bool rawStrings;

  /// A seed can be provided if the obfuscation randomness needs to remain
  /// reproducible across builds.
  /// **Note**: This will make the `Random` instance non-secure!
  final int? randomSeed;

  const Envied({
    String? path,
    bool? requireEnvFile,
    this.name,
    this.obfuscate = false,
    this.allowOptionalFields = false,
    this.environment = false,
    this.useConstantCase = false,
    this.interpolate = true,
    this.rawStrings = false,
    this.randomSeed,
  }) : path = path ?? '.env',
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

  /// When set to `true`, the value set in the `.env` file will not be used as
  /// the ultimate value but will instead be used as the key and the ultimate
  /// value will be read from [Platform.environment].
  final bool? environment;

  /// Allows this field to be optional when the type is nullable.
  ///
  /// With this enabled, the generator will not throw an exception
  /// if the environment variable is missing and a default value was
  /// not set.
  final bool? optional;

  /// Whether to convert the field name to CONSTANT_CASE.
  ///
  /// By default, this is set to `false`, which means that the field name will
  /// retain its original format unless [varName] is specified.
  ///
  /// When set to `true`, the field name will be automatically transformed
  /// into CONSTANT_CASE. This follows the Dart convention for constant
  /// names where all letters are capitalized, and words are separated by
  /// underscores.
  ///
  /// Example:
  /// ```dart
  /// @EnvField(useConstantCase: true)
  /// String apiKey; // Transformed to 'API_KEY'
  /// ```
  final bool? useConstantCase;

  /// Whether to use the interpolated value for the field.
  /// If [interpolate] is `true`, the value will be interpolated
  /// with the environment variables.
  final bool? interpolate;

  /// Whether to use the raw string format for the value.
  ///
  /// Can only be used with a [String] type.
  ///
  /// **NOTE**: The string is always formatted `'<value>'`.
  ///
  /// If [rawString] is `true`, creates a raw String formatted `r'<value>'`
  /// and the value may not contain a single quote.
  /// Escapes single quotes and newlines in the value.
  final bool? rawString;

  /// A seed can be provided if the obfuscation randomness needs to remain
  /// reproducible across builds.
  /// **Note**: This will make the `Random` instance non-secure!
  final int? randomSeed;

  const EnviedField({
    this.varName,
    this.obfuscate,
    this.defaultValue,
    this.environment,
    this.optional,
    this.useConstantCase,
    this.interpolate,
    this.rawString,
    this.randomSeed,
  });
}

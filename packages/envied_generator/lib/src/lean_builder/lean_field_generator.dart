import 'dart:io' show Platform;
import 'dart:math' show Random;

import 'package:code_builder/code_builder.dart';
import 'package:envied/envied.dart';
import 'package:envied_generator/src/env_val.dart';
import 'package:lean_builder/builder.dart';
import 'package:lean_builder/element.dart';
import 'package:lean_builder/type.dart';
import 'package:recase/recase.dart';

import 'build_utils.dart';
import 'lean_envied_resolver.dart';

/// Generates code_builder Field objects for environment variable fields.
///
/// This class is responsible for transforming @EnviedField-annotated fields
/// into actual Dart field declarations with values from environment variables.
/// It handles:
///
/// - **Type conversions**: String, int, double, num, bool, Uri, DateTime, Enum
/// - **Obfuscation**: XOR-based encryption for strings and primitive types
/// - **Optional fields**: Nullable types with default values
/// - **Name conventions**: CONSTANT_CASE transformation
/// - **Interpolation**: Variable substitution in values
/// - **System environment**: Delegation to Platform.environment
///
/// The generator creates either plain fields (constants/finals) or obfuscated
/// fields (with encryption keys and XOR operations).
///
/// Example generated output (plain):
/// ```dart
/// static const String apiKey = 'my_key';
/// ```
///
/// Example generated output (obfuscated):
/// ```dart
/// static final List<int> _enviedkeyapiKey = [123, 456];
/// static final List<int> _envieddataapiKey = [234, 567];
/// static final String apiKey = String.fromCharCodes(...);
/// ```
class LeanFieldGenerator {
  /// The resolved @Envied class-level configuration.
  ///
  /// Provides default values for field-level options and contains the
  /// path to the .env file, obfuscation settings, etc.
  final Envied config;

  /// Map of environment variable names to their values from the .env file.
  ///
  /// Keys are variable names, values contain both raw and interpolated strings.
  final Map<String, EnvVal> envs;

  /// Whether the class has multiple @Envied annotations.
  ///
  /// When true, generates instance fields with @override annotations.
  /// When false, generates static fields.
  final bool multipleAnnotations;

  /// Cached Random instance for consistent seed across fields.
  ///
  /// Created in the constructor if [config.randomSeed] is set. This allows
  /// all obfuscated fields to use the same random sequence for reproducible
  /// builds while still providing security through obfuscation.
  Random? _cachedRandom;

  /// Creates a new field generator with the given configuration.
  ///
  /// Initializes the Random instance if [config.randomSeed] is provided,
  /// ensuring consistent obfuscation keys across builds.
  ///
  /// Parameters:
  /// - [config]: Class-level @Envied configuration
  /// - [envs]: Loaded environment variables from .env file
  /// - [multipleAnnotations]: Whether to generate with @override annotations
  LeanFieldGenerator({
    required this.config,
    required this.envs,
    this.multipleAnnotations = false,
  }) {
    // Initialize Random instance if we have a randomSeed at class level
    if (config.randomSeed != null) {
      _cachedRandom = Random(config.randomSeed!);
    }
  }

  /// Gets or creates a Random instance based on the provided seed.
  ///
  /// Priority order:
  /// 1. Field-specific seed → Creates new Random(fieldSeed)
  /// 2. Cached class-level Random → Returns shared instance
  /// 3. No seed → Returns Random.secure() for cryptographically secure random
  ///
  /// This method ensures reproducible builds when seeds are provided while
  /// maintaining security when no seed is specified.
  ///
  /// Parameters:
  /// - [fieldSeed]: Optional field-level random seed from @EnviedField
  ///
  /// Returns:
  /// A Random instance to use for obfuscation key generation.
  Random _getRandom(int? fieldSeed) {
    if (fieldSeed != null) {
      return Random(fieldSeed);
    }
    if (_cachedRandom != null) {
      return _cachedRandom!;
    }
    return Random.secure();
  }

  /// Generates Field objects for a single @EnviedField-annotated field.
  ///
  /// This is the main entry point for field generation. It:
  /// 1. Validates the field has an explicit type
  /// 2. Resolves the environment variable name (with CONSTANT_CASE if needed)
  /// 3. Looks up the value from .env file, system environment, or default
  /// 4. Determines whether to obfuscate based on configuration
  /// 5. Delegates to appropriate generator method (plain or obfuscated)
  ///
  /// The method handles field-level configuration overrides (obfuscate, optional,
  /// useConstantCase, etc.) by preferring field-specific values over class defaults.
  ///
  /// Parameters:
  /// - [field]: The field element from the source class
  /// - [fieldConfig]: Resolved @EnviedField configuration
  ///
  /// Returns:
  /// An iterable of [Field] objects to add to the generated class.
  /// For plain fields: one Field
  /// For obfuscated fields: multiple Fields (keys, data, result)
  ///
  /// Throws:
  /// [InvalidGenerationSourceError] if the field type is invalid, the
  /// environment variable is missing, or type conversion fails.
  Iterable<Field> generateForField(
    FieldElement field,
    EnviedFieldConfig fieldConfig,
  ) {
    // Early type validation
    if (field.type.name == null || field.type.name == 'InvalidType') {
      throw InvalidGenerationSourceError(
        ErrorMessages.typeNotDeclared(field.name),
        element: field,
      );
    }

    // Cache type information for reuse
    final String typeName = field.type.name ?? 'dynamic';
    final bool isNullable =
        field.type.name == 'dynamic' || field.type.isNullable;

    // Determine variable name
    late String varName;
    final bool environment = fieldConfig.environment ?? config.environment;
    final bool useConstantCase =
        fieldConfig.useConstantCase ?? config.useConstantCase;

    if (fieldConfig.varName == null) {
      varName = useConstantCase ? field.name.constantCase : field.name;
    } else {
      varName = fieldConfig.varName!;
    }

    final Object? defaultValue = fieldConfig.defaultValue;

    // Find environment value
    late final EnvVal? varValue;

    if (environment) {
      final String? envKey = envs[varName]?.raw;
      if (envKey == null) {
        throw InvalidGenerationSourceError(
          ErrorMessages.envEntryMissing(varName, field.name),
          element: field,
        );
      }
      final String? env = Platform.environment[envKey];
      if (env == null) {
        throw InvalidGenerationSourceError(
          ErrorMessages.systemEnvMissing(envKey, field.name),
          element: field,
        );
      }

      varValue = EnvVal(raw: env);
    } else if (envs.containsKey(varName)) {
      varValue = envs[varName];
    } else if (Platform.environment.containsKey(varName)) {
      varValue = EnvVal(raw: Platform.environment[varName]!);
    } else {
      varValue =
          defaultValue != null ? EnvVal(raw: defaultValue.toString()) : null;
    }

    final bool optional = fieldConfig.optional ?? config.allowOptionalFields;
    final bool interpolate = fieldConfig.interpolate ?? config.interpolate;
    final bool rawString = fieldConfig.rawString ?? config.rawStrings;

    // Check nullability and value availability
    if (varValue == null && !(optional && isNullable)) {
      throw InvalidGenerationSourceError(
        ErrorMessages.envVarNotFound(field.name),
        element: field,
      );
    }

    final bool obfuscate = fieldConfig.obfuscate ?? config.obfuscate;

    return obfuscate
        ? _generateFieldsEncryptedLean(
            field,
            typeName,
            isNullable,
            interpolate ? varValue?.interpolated : varValue?.raw,
            allowOptional: optional,
            randomSeed: fieldConfig.randomSeed ?? config.randomSeed,
            multipleAnnotations: multipleAnnotations,
          )
        : _generateFieldsLean(
            field,
            typeName,
            isNullable,
            interpolate ? varValue?.interpolated : varValue?.raw,
            allowOptional: optional,
            rawString: rawString,
            multipleAnnotations: multipleAnnotations,
          );
  }

  /// Generates plain (non-obfuscated) field declarations.
  ///
  /// Creates a single Field with the environment variable value directly
  /// assigned. For primitive types (int, bool, num), generates `const` fields.
  /// For complex types (Uri, DateTime, Enum), generates `final` fields with
  /// constructor calls.
  ///
  /// The method performs type-specific validation and conversion:
  /// - Numeric types: Validates value can be parsed as num/int/double
  /// - bool: Validates value is 'true' or 'false'
  /// - Uri: Validates value is a valid URI
  /// - DateTime: Validates value can be parsed as ISO 8601
  /// - Enum: Looks up by name in enum.values
  /// - String: Direct assignment with optional raw string (r'...')
  ///
  /// Parameters:
  /// - [field]: The field element being generated
  /// - [typeName]: The cached type name (e.g., 'String', 'int')
  /// - [isNullable]: Whether the type is nullable
  /// - [value]: The environment variable value, or null for optional fields
  /// - [allowOptional]: Whether null values are allowed
  /// - [rawString]: Whether to use raw string literals (r'...')
  /// - [multipleAnnotations]: Whether to add @override annotation
  ///
  /// Returns:
  /// A single-element iterable containing the generated Field.
  ///
  /// Throws:
  /// [InvalidGenerationSourceError] if type validation fails.
  Iterable<Field> _generateFieldsLean(
    FieldElement field,
    String typeName,
    bool isNullable,
    String? value, {
    bool allowOptional = false,
    bool rawString = false,
    bool multipleAnnotations = false,
  }) {
    final bool isDynamic = typeName == 'dynamic';

    late final FieldModifier modifier;
    late final Expression result;

    if (value == null) {
      if (!allowOptional) {
        throw InvalidGenerationSourceError(
          ErrorMessages.envVarNotFound(field.name),
          element: field,
        );
      }

      modifier = FieldModifier.constant;
      result = literalNull;
    } else {
      if (_isNumericType(typeName)) {
        final num? parsed = num.tryParse(value);
        if (parsed == null) {
          throwError(ErrorMessages.typeValueMismatch(typeName, value),
              element: field);
        }
        modifier = FieldModifier.constant;
        result = literalNum(parsed!);
      } else if (typeName == 'bool') {
        final bool? parsed = bool.tryParse(value);
        if (parsed == null) {
          throwError(ErrorMessages.typeValueMismatch(typeName, value),
              element: field);
        }
        modifier = FieldModifier.constant;
        result = literalBool(parsed!);
      } else if (typeName == 'Uri') {
        final Uri? parsed = Uri.tryParse(value);
        if (parsed == null) {
          throwError(ErrorMessages.typeValueMismatch(typeName, value),
              element: field);
        }
        modifier = FieldModifier.final$;
        result =
            refer('Uri').type.newInstanceNamed('parse', [literalString(value)]);
      } else if (typeName == 'DateTime') {
        final DateTime? parsed = DateTime.tryParse(value);
        if (parsed == null) {
          throwError(ErrorMessages.typeValueMismatch(typeName, value),
              element: field);
        }
        modifier = FieldModifier.final$;
        result = refer('DateTime')
            .type
            .newInstanceNamed('parse', [literalString(value)]);
      } else if (_isEnumType(field.type)) {
        modifier = FieldModifier.final$;
        result = refer(typeName)
            .type
            .property('values')
            .property('byName')
            .call([literalString(value)]);
      } else if (typeName == 'String' || isDynamic) {
        modifier = FieldModifier.constant;
        result = literalString(value, raw: rawString);
      } else {
        throwError(
          ErrorMessages.unsupportedType(typeName),
          element: field,
        );
      }
    }

    // Cache type display string
    final String? typeRef = !isDynamic
        ? _getTypeDisplayString(field.type, withNullability: allowOptional)
        : null;

    return [
      Field(
        (fieldBuilder) => fieldBuilder
          ..annotations.addAll([if (multipleAnnotations) refer('override')])
          ..static = !multipleAnnotations
          ..modifier = !multipleAnnotations ? modifier : FieldModifier.final$
          ..type = typeRef != null ? refer(typeRef) : null
          ..name = field.name
          ..assignment = result.code,
      ),
    ];
  }

  /// Generates obfuscated/encrypted field declarations.
  ///
  /// Creates multiple Fields that work together to provide obfuscated access
  /// to environment variables:
  /// 1. Key field(s): Random encryption keys
  /// 2. Data field(s): XOR-encrypted values
  /// 3. Result field: Decrypts and returns the actual value
  ///
  /// Obfuscation techniques by type:
  /// - **int/bool**: Simple XOR with random key
  /// - **String-based types**: Character-by-character XOR with random key arrays
  ///   - Each character is XOR'd with a different random number
  ///   - Reconstruction uses String.fromCharCodes with XOR reversal
  ///
  /// The obfuscation makes it harder (but not impossible) to extract values
  /// from compiled code. For maximum security, use environment variables at
  /// runtime instead of compile-time obfuscation.
  ///
  /// Parameters:
  /// - [field]: The field element being generated
  /// - [typeName]: The cached type name (e.g., 'String', 'int')
  /// - [isNullable]: Whether the type is nullable
  /// - [value]: The environment variable value, or null for optional fields
  /// - [allowOptional]: Whether null values are allowed
  /// - [randomSeed]: Optional seed for Random (defaults to class/secure random)
  /// - [multipleAnnotations]: Whether to add @override annotation
  ///
  /// Returns:
  /// Multiple Fields (key, data, and result) that work together for obfuscation.
  ///
  /// Throws:
  /// [InvalidGenerationSourceError] if type validation fails or the type
  /// doesn't support obfuscation.
  Iterable<Field> _generateFieldsEncryptedLean(
    FieldElement field,
    String typeName,
    bool isNullable,
    String? value, {
    bool allowOptional = false,
    int? randomSeed,
    bool multipleAnnotations = false,
  }) {
    final String keyName = '_enviedkey${field.name}';

    if (value == null) {
      if (!allowOptional) {
        throwError(ErrorMessages.envVarNotFound(field.name), element: field);
      }
      return [
        Field(
          (fb) => fb
            ..static = true
            ..modifier = FieldModifier.final$
            ..type =
                refer(_getTypeDisplayString(field.type, withNullability: true))
            ..name = field.name
            ..assignment = literalNull.code,
        ),
      ];
    }

    // Use shared Random instance or create new one
    final rand = _getRandom(randomSeed);

    if (typeName == 'int') {
      final int? parsed = int.tryParse(value);
      if (parsed == null) {
        throwError(ErrorMessages.typeValueMismatch(typeName, value),
            element: field);
      }

      final int key = rand.nextInt(1 << 32);
      final int encValue = parsed! ^ key;

      return [
        Field((fb) => fb
          ..static = true
          ..modifier = FieldModifier.final$
          ..type = refer('int')
          ..name = keyName
          ..assignment = literalNum(key).code),
        Field((fb) => fb
          ..static = true
          ..modifier = FieldModifier.final$
          ..type = TypeReference((b) => b
            ..symbol = 'int'
            ..isNullable = isNullable)
          ..name = field.name
          ..assignment =
              refer(keyName).operatorBitwiseXor(literalNum(encValue)).code),
      ];
    }

    if (typeName == 'bool') {
      final bool? parsed = bool.tryParse(value);
      if (parsed == null) {
        throwError(ErrorMessages.typeValueMismatch(typeName, value),
            element: field);
      }

      final bool key = rand.nextBool();
      final bool encValue = parsed! ^ key;

      return [
        Field((fb) => fb
          ..static = true
          ..modifier = FieldModifier.final$
          ..type = refer('bool')
          ..name = keyName
          ..assignment = literalBool(key).code),
        Field((fb) => fb
          ..static = true
          ..modifier = FieldModifier.final$
          ..type = TypeReference((b) => b
            ..symbol = 'bool'
            ..isNullable = isNullable)
          ..name = field.name
          ..assignment =
              refer(keyName).operatorBitwiseXor(literalBool(encValue)).code),
      ];
    }

    // For string-based types (String, double, num, Uri, DateTime, Enum)
    if (_isStringBasedType(typeName) || _isEnumType(field.type)) {
      _validateStringBasedType(typeName, value, field);

      final List<int> parsed = value.codeUnits;
      final int length = parsed.length;

      // Optimized single-pass list generation for key and encrypted value
      final List<int> key =
          List.generate(length, (_) => rand.nextInt(1 << 32), growable: false);
      final List<int> encValue =
          List.generate(length, (i) => parsed[i] ^ key[i], growable: false);
      final String encName = '_envieddata${field.name}';

      final Expression stringExpression =
          _createStringFromChars(keyName, encName);
      final (String? symbol, Expression result) =
          _createResultExpression(typeName, field.type, stringExpression);
      final isDynamic = typeName == 'dynamic';

      return [
        Field((fb) => fb
          ..static = true
          ..modifier = FieldModifier.constant
          ..type = TypeReference((tb) => tb
            ..symbol = 'List'
            ..types.add(refer('int')))
          ..name = keyName
          ..assignment = literalList(key, refer('int')).code),
        Field((fb) => fb
          ..static = true
          ..modifier = FieldModifier.constant
          ..type = TypeReference((tb) => tb
            ..symbol = 'List'
            ..types.add(refer('int')))
          ..name = encName
          ..assignment = literalList(encValue, refer('int')).code),
        Field((fb) => fb
          ..annotations.addAll([if (multipleAnnotations) refer('override')])
          ..static = !multipleAnnotations
          ..modifier = FieldModifier.final$
          ..type = !isDynamic
              ? TypeReference((tb) => tb
                ..symbol = symbol
                ..isNullable = isNullable)
              : null
          ..name = field.name
          ..assignment = result.code),
      ];
    }

    throwError(
      ErrorMessages.unsupportedType(typeName, obfuscated: true),
      element: field,
    );

    return []; // Unreachable but satisfies return type
  }

  // Helper methods
  bool _isNumericType(String typeName) =>
      typeName == 'int' || typeName == 'double' || typeName == 'num';

  bool _isStringBasedType(String typeName) =>
      typeName == 'String' ||
      typeName == 'double' ||
      typeName == 'num' ||
      typeName == 'Uri' ||
      typeName == 'DateTime';

  bool _isEnumType(DartType type) {
    // Check if it's an enum by checking if the element is an EnumElement
    return type is NamedDartType && type.element is EnumElement;
  }

  String _getTypeDisplayString(DartType type, {required bool withNullability}) {
    final name = type.name ?? 'dynamic';
    if (withNullability && type.isNullable) {
      return '$name?';
    }
    return name;
  }

  void _validateStringBasedType(
      String typeName, String value, FieldElement field) {
    if ((typeName == 'Uri' && Uri.tryParse(value) == null) ||
        (typeName == 'DateTime' && DateTime.tryParse(value) == null) ||
        ((typeName == 'double' || typeName == 'num') &&
            num.tryParse(value) == null)) {
      throwError(ErrorMessages.typeValueMismatch(typeName, value),
          element: field);
    }
  }

  Expression _createStringFromChars(String keyName, String encName) {
    return refer('String').type.newInstanceNamed(
      'fromCharCodes',
      [
        TypeReference((tb) => tb
              ..symbol = 'List'
              ..types.add(refer('int')))
            .type
            .newInstanceNamed(
              'generate',
              [
                refer(encName).property('length'),
                Method((method) => method
                  ..lambda = true
                  ..requiredParameters.add(Parameter((p) => p
                    ..name = 'i'
                    ..type = refer('int')))
                  ..body = refer('i').code).closure,
              ],
              {'growable': literalFalse},
            )
            .property('map')
            .call([
              Method((mb) => mb
                ..lambda = true
                ..requiredParameters.add(Parameter((pb) => pb
                  ..name = 'i'
                  ..type = refer('int')))
                ..body = refer(encName)
                    .index(refer('i'))
                    .operatorBitwiseXor(refer(keyName).index(refer('i')))
                    .code).closure,
            ]),
      ],
    );
  }

  (String?, Expression) _createResultExpression(
      String typeName, DartType type, Expression stringExpression) {
    if (typeName == 'double' || typeName == 'num') {
      return (
        typeName,
        refer(typeName).type.newInstanceNamed('parse', [stringExpression])
      );
    } else if (typeName == 'Uri') {
      return (
        'Uri',
        refer('Uri').type.newInstanceNamed('parse', [stringExpression])
      );
    } else if (typeName == 'DateTime') {
      return (
        'DateTime',
        refer('DateTime').type.newInstanceNamed('parse', [stringExpression])
      );
    } else if (_isEnumType(type)) {
      final symbol = type.name;
      return (
        symbol,
        refer(symbol!)
            .type
            .property('values')
            .property('byName')
            .call([stringExpression])
      );
    } else {
      return (typeName != 'dynamic' ? 'String' : null, stringExpression);
    }
  }
}

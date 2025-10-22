import 'package:envied/envied.dart';
import 'package:lean_builder/element.dart';
import 'package:lean_builder/type.dart';

import 'build_utils.dart';

/// Resolves @Envied and @EnviedField annotations from lean_builder elements.
///
/// This class extracts configuration from Dart annotations and converts them
/// into strongly-typed [Envied] and [EnviedFieldConfig] objects. It handles
/// the complexity of reading annotation values from lean_builder's [ConstObject]
/// representation.
///
/// The resolver provides a centralized way to parse annotation configurations,
/// ensuring consistent handling of defaults and type conversions throughout
/// the code generation process.
///
/// Example usage:
/// ```dart
/// final resolver = LeanEnviedResolver();
/// final config = resolver.resolveEnviedConfig(annotation, overridePath);
/// final fieldConfig = resolver.resolveEnviedField(fieldAnnotation);
/// ```
class LeanEnviedResolver {
  /// Helper to safely extract boolean value from annotation.
  ///
  /// Returns `null` if the key doesn't exist or isn't a boolean constant.
  /// This prevents crashes when annotation parameters are optional or have
  /// unexpected types.
  ///
  /// Parameters:
  /// - [annotation]: The annotation object to read from
  /// - [key]: The parameter name to extract
  bool? _safeBool(ConstObject annotation, String key) {
    final value = annotation.get(key);
    if (value == null) return null;
    if (value is ConstBool) return value.value;
    return null;
  }

  /// Helper to safely extract integer value from annotation.
  ///
  /// Returns `null` if the key doesn't exist or isn't an integer constant.
  /// Used for parameters like `randomSeed`.
  ///
  /// Parameters:
  /// - [annotation]: The annotation object to read from
  /// - [key]: The parameter name to extract
  int? _safeInt(ConstObject annotation, String key) {
    final value = annotation.get(key);
    if (value == null) return null;
    if (value is ConstInt) return value.value;
    return null;
  }

  /// Helper to safely extract string value from annotation.
  ///
  /// Returns `null` if the key doesn't exist or isn't a string constant.
  /// Used for parameters like `path`, `name`, and `varName`.
  ///
  /// Parameters:
  /// - [annotation]: The annotation object to read from
  /// - [key]: The parameter name to extract
  String? _safeString(ConstObject annotation, String key) {
    final value = annotation.get(key);
    if (value == null) return null;
    if (value is ConstString) return value.value;
    return null;
  }

  /// Resolves the @Envied class-level annotation configuration.
  ///
  /// Extracts all configuration options from an @Envied annotation and creates
  /// an [Envied] configuration object. The [overridePath] parameter takes
  /// precedence over the annotation's path parameter, allowing build-time
  /// path overrides via build.yaml.
  ///
  /// Parameters:
  /// - [annotation]: The @Envied annotation constant object
  /// - [overridePath]: Optional path override from build configuration
  ///
  /// Returns:
  /// An [Envied] configuration object with all parameters resolved to their
  /// specified values or defaults.
  ///
  /// Example:
  /// ```dart
  /// // For: @Envied(path: '.env', obfuscate: true)
  /// final config = resolver.resolveEnviedConfig(annotation, null);
  /// // config.path == '.env'
  /// // config.obfuscate == true
  /// // config.requireEnvFile == false (default)
  /// ```
  Envied resolveEnviedConfig(ConstObject annotation, String? overridePath) {
    return Envied(
      path: overridePath ?? _safeString(annotation, 'path'),
      requireEnvFile: _safeBool(annotation, 'requireEnvFile') ?? false,
      name: _safeString(annotation, 'name'),
      obfuscate: _safeBool(annotation, 'obfuscate') ?? false,
      allowOptionalFields:
          _safeBool(annotation, 'allowOptionalFields') ?? false,
      environment: _safeBool(annotation, 'environment') ?? false,
      useConstantCase: _safeBool(annotation, 'useConstantCase') ?? false,
      interpolate: _safeBool(annotation, 'interpolate') ?? true,
      rawStrings: _safeBool(annotation, 'rawStrings') ?? false,
      randomSeed: _safeInt(annotation, 'randomSeed'),
    );
  }

  /// Resolves the @EnviedField field-level annotation configuration.
  ///
  /// Extracts all configuration options from an @EnviedField annotation and
  /// creates an [EnviedFieldConfig] object. Field-level configurations can
  /// override class-level settings from @Envied.
  ///
  /// Parameters:
  /// - [annotation]: The @EnviedField annotation constant object
  ///
  /// Returns:
  /// An [EnviedFieldConfig] object with all field-specific parameters.
  ///
  /// Example:
  /// ```dart
  /// // For: @EnviedField(varName: 'API_KEY', obfuscate: true)
  /// final config = resolver.resolveEnviedField(annotation);
  /// // config.varName == 'API_KEY'
  /// // config.obfuscate == true
  /// // config.optional == null (inherits from class)
  /// ```
  EnviedFieldConfig resolveEnviedField(ConstObject annotation) {
    return EnviedFieldConfig(
      varName: _safeString(annotation, 'varName'),
      obfuscate: _safeBool(annotation, 'obfuscate'),
      defaultValue: _getDefaultValue(annotation.get('defaultValue')),
      environment: _safeBool(annotation, 'environment'),
      optional: _safeBool(annotation, 'optional'),
      useConstantCase: _safeBool(annotation, 'useConstantCase'),
      interpolate: _safeBool(annotation, 'interpolate'),
      rawString: _safeBool(annotation, 'rawString'),
      randomSeed: _safeInt(annotation, 'randomSeed'),
    );
  }

  /// Extracts the actual value from a [Constant] annotation parameter.
  ///
  /// Handles different constant types from lean_builder's type system:
  /// - [ConstString]: String literals
  /// - [ConstInt]: Integer literals
  /// - [ConstDouble]: Double literals
  /// - [ConstBool]: Boolean literals
  /// - [ConstLiteral]: Generic literal values
  ///
  /// Used primarily for extracting `defaultValue` from @EnviedField.
  ///
  /// Returns:
  /// The primitive value from the constant, or `null` if the constant is
  /// null or of an unsupported type.
  Object? _getDefaultValue(Constant? constant) {
    if (constant == null) return null;

    // Based on lean_builder docs, check constant types
    if (constant is ConstString) {
      return constant.value;
    }
    if (constant is ConstInt) {
      return constant.value;
    }
    if (constant is ConstDouble) {
      return constant.value;
    }
    if (constant is ConstBool) {
      return constant.value;
    }
    if (constant is ConstLiteral) {
      return constant.literalValue;
    }

    return null;
  }

  /// Resolves complete field information including type validation.
  ///
  /// This method combines field element inspection with annotation resolution
  /// to create a complete [EnviedFieldInfo] object. It validates that the
  /// field has an explicit type declaration.
  ///
  /// Parameters:
  /// - [field]: The field element from the analyzed class
  /// - [annotation]: The @EnviedField annotation on this field
  ///
  /// Returns:
  /// An [EnviedFieldInfo] object containing the field's name, type, and
  /// resolved configuration.
  ///
  /// Throws:
  /// [InvalidGenerationSourceError] if the field doesn't have an explicit type.
  ///
  /// Note: This method is currently unused but kept for potential future use
  /// or API completeness.
  EnviedFieldInfo resolveFieldInfo(FieldElement field, ConstObject annotation) {
    throwIf(
      field.type is InvalidType,
      'Envied requires types to be explicitly declared. `${field.name}` does not declare a type.',
      element: field,
    );

    final config = resolveEnviedField(annotation);

    return EnviedFieldInfo(
      name: field.name,
      type: field.type,
      config: config,
    );
  }
}

/// Configuration extracted from @EnviedField annotation.
///
/// Holds all the field-level configuration options that can be specified
/// in an @EnviedField annotation. `null` values indicate that the parameter
/// wasn't specified and should inherit from the class-level @Envied config.
///
/// This immutable data class makes it easy to pass field configuration
/// throughout the generation pipeline without directly coupling to
/// annotation objects.
class EnviedFieldConfig {
  /// The name of the environment variable to look up.
  ///
  /// If null, the field name (possibly converted to CONSTANT_CASE) is used.
  final String? varName;

  /// Whether to obfuscate/encrypt this field's value.
  ///
  /// If null, inherits from the class-level setting.
  final bool? obfuscate;

  /// Default value to use if the environment variable is not found.
  ///
  /// Can be a String, int, double, or bool.
  final Object? defaultValue;

  /// Whether to treat the .env value as a key for a system environment variable.
  ///
  /// If null, inherits from the class-level setting.
  final bool? environment;

  /// Whether this field is optional (can be null).
  ///
  /// If null, inherits from the class-level setting.
  final bool? optional;

  /// Whether to convert the field name to CONSTANT_CASE for lookup.
  ///
  /// If null, inherits from the class-level setting.
  final bool? useConstantCase;

  /// Whether to interpolate variables like ${VAR} in the value.
  ///
  /// If null, inherits from the class-level setting.
  final bool? interpolate;

  /// Whether to use raw strings (r'...') for this field.
  ///
  /// If null, inherits from the class-level setting.
  final bool? rawString;

  /// Seed for the random number generator used in obfuscation.
  ///
  /// If null, inherits from the class-level setting or uses Random.secure().
  final int? randomSeed;

  /// Creates a new field configuration with the specified parameters.
  const EnviedFieldConfig({
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

/// Complete information about a field with @EnviedField annotation.
///
/// Combines the field's metadata (name, type) with its resolved configuration.
/// This provides all the information needed to generate code for a single
/// environment variable field.
///
/// Note: Currently unused but kept for potential future use or to maintain
/// API completeness for the resolver.
class EnviedFieldInfo {
  /// The Dart field name.
  final String name;

  /// The Dart type of the field.
  final DartType type;

  /// The resolved configuration from the @EnviedField annotation.
  final EnviedFieldConfig config;

  /// Creates a new field info object.
  const EnviedFieldInfo({
    required this.name,
    required this.type,
    required this.config,
  });
}

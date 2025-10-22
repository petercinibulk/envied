import 'package:lean_builder/builder.dart';
import 'package:lean_builder/element.dart';

/// Helper to throw errors if [condition] is true.
///
/// This is a convenience function to avoid repetitive if-throw patterns.
/// If [condition] is true, throws an [InvalidGenerationSourceError] with
/// the provided [message] and optional [element] for context.
///
/// Example:
/// ```dart
/// throwIf(field.type == null, 'Field type must be declared', element: field);
/// ```
void throwIf(bool condition, String message, {Element? element}) {
  if (condition) {
    throwError(message, element: element);
  }
}

/// Helper to throw build-time errors with optional element context.
///
/// Throws an [InvalidGenerationSourceError] which is the standard exception
/// type for code generation errors in the build system. The [element] parameter
/// helps pinpoint the source location that caused the error.
///
/// Example:
/// ```dart
/// throwError('Invalid type: $typeName', element: field);
/// ```
void throwError(String message, {Element? element}) {
  throw InvalidGenerationSourceError(message, element: element);
}

/// Centralized error message templates for consistent error reporting.
///
/// This class provides static factory methods that generate standardized
/// error messages used throughout the envied generator. Using templates
/// ensures consistency and makes it easier to maintain error messages.
///
/// All methods return formatted error strings that can be passed to
/// [throwError] or thrown directly as [InvalidGenerationSourceError].
class ErrorMessages {
  /// Error when a field type is not explicitly declared.
  ///
  /// Envied requires all fields to have explicit types. This error is thrown
  /// when a field is missing its type annotation or has an invalid type.
  ///
  /// Example output: "Envied requires types to be explicitly declared. `apiKey` does not declare a type."
  static String typeNotDeclared(String fieldName) =>
      'Envied requires types to be explicitly declared. `$fieldName` does not declare a type.';

  /// Error when a type doesn't match the value from the environment.
  ///
  /// This occurs when trying to parse an environment variable value into
  /// a specific Dart type (e.g., parsing "abc" as an int).
  ///
  /// Example output: "Type `int` does not align with value `abc`."
  static String typeValueMismatch(String typeName, String value) =>
      'Type `$typeName` does not align with value `$value`.';

  /// Error when an environment variable is not found.
  ///
  /// This error is thrown when the generator cannot find a value for a
  /// required field in either the .env file or system environment variables.
  ///
  /// Example output: "Environment variable not found for field `apiKey`."
  static String envVarNotFound(String fieldName) =>
      'Environment variable not found for field `$fieldName`.';

  /// Error when a .env file entry is missing.
  ///
  /// Used specifically when [environment] mode is enabled and the .env file
  /// doesn't contain the expected key that should point to a system environment variable.
  ///
  /// Example output: "Expected to find an .env entry with a key of `API_KEY` for field `apiKey` but none was found."
  static String envEntryMissing(String varName, String fieldName) =>
      'Expected to find an .env entry with a key of `$varName` for field `$fieldName` but none was found.';

  /// Error when a system environment variable is missing.
  ///
  /// Used in [environment] mode when the system doesn't have the environment
  /// variable that the .env file points to.
  ///
  /// Example output: "Expected to find a System environment variable named `PROD_API_KEY` for field `apiKey` but no value was found."
  static String systemEnvMissing(String envKey, String fieldName) =>
      'Expected to find a System environment variable named `$envKey` for field `$fieldName` but no value was found.';

  /// Error when a type is not supported by envied.
  ///
  /// Envied supports a specific set of types. This error is thrown when
  /// a field uses an unsupported type. The [obfuscated] parameter indicates
  /// whether the error occurred in obfuscation mode.
  ///
  /// Supported types: `int`, `double`, `num`, `bool`, `Uri`, `DateTime`, `Enum`, `String`
  ///
  /// Example output: "Envied can only handle types such as `int`, `double`, `num`, `bool`, `Uri`, `DateTime`, `Enum` and `String`. Type `Map` is not one of them."
  static String unsupportedType(String typeName, {bool obfuscated = false}) {
    final prefix = obfuscated ? 'Obfuscated envied' : 'Envied';
    return '$prefix can only handle types such as `int`, `double`, `num`, '
        '`bool`, `Uri`, `DateTime`, `Enum` and `String`. '
        'Type `$typeName` is not one of them.';
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

/// Generate the line to be used in the generated class.
/// If [value] is `null`, it means the variable definition doesn't exist
/// and an [InvalidGenerationSourceError] will be thrown.
///
/// Since this function also does the type casting,
/// an [InvalidGenerationSourceError] will also be thrown if
/// the type can't be casted, or is not supported.
String generateLine(FieldElement field, String? value) {
  if (value == null) {
    throw InvalidGenerationSourceError(
      'Environment variable not found for field `${field.name}`.',
      element: field,
    );
  }

  final type = field.type.getDisplayString(withNullability: false);

  final parsedValue = ((String t) {
    switch (t) {
      case "int":
        final result = int.tryParse(value);
        if (result == null) {
          throw InvalidGenerationSourceError(
            'Type `$t` do not align up to value `$value`.',
            element: field,
          );
        } else {
          return result;
        }
      case "double":
        final result = double.tryParse(value);
        if (result == null) {
          throw InvalidGenerationSourceError(
            'Type `$t` do not align up to value `$value`.',
            element: field,
          );
        } else {
          return result;
        }
      case "num":
        final result = num.tryParse(value);
        if (result == null) {
          throw InvalidGenerationSourceError(
            'Type `$t` do not align up to value `$value`.',
            element: field,
          );
        } else {
          return result;
        }
      case "bool":
        final lowercaseValue = value.toLowerCase();
        if (['true', 'false'].contains(lowercaseValue)) {
          return lowercaseValue;
        } else {
          throw InvalidGenerationSourceError(
            'Type `$t` do not align up to value `$value`.',
            element: field,
          );
        }
      case "String":
      case "dynamic":
        return "'$value'";
      default:
        throw InvalidGenerationSourceError(
          'Envied can only handle types such as `int`, `double`, `num`, `bool` and `String`. Type `$t` is not one of them.',
          element: field,
        );
    }
  })(type);

  return 'static const ${type != 'dynamic' ? type : ''} ${field.name} = $parsedValue;';
}

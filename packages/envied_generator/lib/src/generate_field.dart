import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

/// Generate the [Field]s to be used in the generated class.
/// If [value] is `null`, it means the variable definition doesn't exist
/// and an [InvalidGenerationSourceError] will be thrown.
///
/// Since this function also does the type casting,
/// an [InvalidGenerationSourceError] will also be thrown if
/// the type can't be casted, or is not supported.
Iterable<Field> generateFields(
  FieldElement field,
  String? value, {
  required bool allowOptional,
}) {
  final String type = field.type.getDisplayString(withNullability: false);

  late final Expression result;

  if (value == null) {
    if (!allowOptional) {
      throw InvalidGenerationSourceError(
        'Environment variable not found for field `${field.name}`.',
        element: field,
      );
    }

    // Early return if null, so need to check for allowed types
    if (!field.type.isDartCoreInt &&
        !field.type.isDartCoreDouble &&
        !field.type.isDartCoreNum &&
        !field.type.isDartCoreBool &&
        !field.type.isDartCoreString &&
        field.type is! DynamicType) {
      throw InvalidGenerationSourceError(
        'Envied can only handle types such as `int`, `double`, `num`, `bool` and'
        ' `String`. Type `$type` is not one of them.',
        element: field,
      );
    }

    return [
      Field(
        (FieldBuilder fieldBuilder) => fieldBuilder
          ..static = true
          ..modifier = FieldModifier.constant
          ..type = refer(field.type is DynamicType
              ? ''
              : field.type.getDisplayString(withNullability: true))
          ..name = field.name
          ..assignment = Code('null'),
      ),
    ];
  }

  if (field.type.isDartCoreInt ||
      field.type.isDartCoreDouble ||
      field.type.isDartCoreNum) {
    final num? parsed = num.tryParse(value);

    if (parsed == null) {
      throw InvalidGenerationSourceError(
        'Type `$type` do not align up to value `$value`.',
        element: field,
      );
    }

    result = literalNum(parsed);
  } else if (field.type.isDartCoreBool) {
    final bool? parsed = bool.tryParse(value);

    if (parsed == null) {
      throw InvalidGenerationSourceError(
        'Type `$type` do not align up to value `$value`.',
        element: field,
      );
    }

    result = literalBool(parsed);
  } else if (field.type.isDartCoreString || field.type is DynamicType) {
    result = literalString(value);
  } else {
    throw InvalidGenerationSourceError(
      'Envied can only handle types such as `int`, `double`, `num`, `bool` and'
      ' `String`. Type `$type` is not one of them.',
      element: field,
    );
  }

  return [
    Field(
      (FieldBuilder fieldBuilder) => fieldBuilder
        ..static = true
        ..modifier = FieldModifier.constant
        ..type = refer(
          field.type is DynamicType
              ? ''
              : field.type.getDisplayString(withNullability: allowOptional),
        )
        ..name = field.name
        ..assignment = result.code,
    ),
  ];
}

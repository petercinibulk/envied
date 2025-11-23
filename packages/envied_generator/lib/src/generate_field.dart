// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:envied_generator/src/extensions.dart';
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
  bool allowOptional = false,
  bool rawString = false,
  bool multipleAnnotations = false,
}) {
  final String type = field.type.getDisplayString(withNullability: false);

  late final FieldModifier modifier;
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
        !field.type.isDartCoreUri &&
        !field.type.isDartCoreDateTime &&
        !field.type.isDartEnum &&
        !field.type.isDartCoreString &&
        field.type is! DynamicType) {
      throw InvalidGenerationSourceError(
        'Envied can only handle types such as `int`, `double`, `num`, '
        '`bool`, `Uri`, `DateTime`, `Enum` and `String`. '
        'Type `$type` is not one of them.',
        element: field,
      );
    }

    modifier = FieldModifier.constant;
    result = literalNull;
  } else {
    if (field.type.isDartCoreInt ||
        field.type.isDartCoreDouble ||
        field.type.isDartCoreNum) {
      final num? parsed = num.tryParse(value);

      if (parsed == null) {
        throw InvalidGenerationSourceError(
          'Type `$type` does not align with value `$value`.',
          element: field,
        );
      }

      modifier = FieldModifier.constant;
      result = literalNum(parsed);
    } else if (field.type.isDartCoreBool) {
      final bool? parsed = bool.tryParse(value);

      if (parsed == null) {
        throw InvalidGenerationSourceError(
          'Type `$type` does not align with value `$value`.',
          element: field,
        );
      }

      modifier = FieldModifier.constant;
      result = literalBool(parsed);
    } else if (field.type.isDartCoreUri) {
      final Uri? parsed = Uri.tryParse(value);

      if (parsed == null) {
        throw InvalidGenerationSourceError(
          'Type `$type` does not align with value `$value`.',
          element: field,
        );
      }

      modifier = FieldModifier.final$;
      result = refer(
        'Uri',
      ).type.newInstanceNamed('parse', [literalString(value)]);
    } else if (field.type.isDartCoreDateTime) {
      final DateTime? parsed = DateTime.tryParse(value);

      if (parsed == null) {
        throw InvalidGenerationSourceError(
          'Type `$type` does not align with value `$value`.',
          element: field,
        );
      }

      modifier = FieldModifier.final$;
      result = refer(
        'DateTime',
      ).type.newInstanceNamed('parse', [literalString(value)]);
    } else if (field.type.isDartEnum) {
      final EnumElement enumElement = field.type.element as EnumElement;

      if (!enumElement.valueNames.contains(value)) {
        throw InvalidGenerationSourceError(
          'Enumerated type `$type` does not contain value `$value`. '
          'Possible values are: ${enumElement.valueNames.map((el) => '`$el`').join(', ')}.',
          element: field,
        );
      }

      modifier = FieldModifier.final$;
      result = refer(
        type,
      ).type.property('values').property('byName').call([literalString(value)]);
    } else if (field.type.isDartCoreString) {
      modifier = FieldModifier.constant;
      result = literalString(value, raw: rawString);
    } else if (field.type is DynamicType) {
      modifier = FieldModifier.constant;
      result = literalString(value);
    } else {
      throw InvalidGenerationSourceError(
        'Envied can only handle types such as `int`, `double`, `num`, '
        '`bool`, `Uri`, `DateTime`, `Enum` and `String`. '
        'Type `$type` is not one of them.',
        element: field,
      );
    }
  }

  return [
    Field(
      (FieldBuilder fieldBuilder) => fieldBuilder
        ..annotations.addAll([if (multipleAnnotations) refer('override')])
        ..static = !multipleAnnotations
        ..modifier = !multipleAnnotations ? modifier : FieldModifier.final$
        ..type = field.type is! DynamicType
            ? refer(field.type.getDisplayString(withNullability: allowOptional))
            : null
        ..name = field.name
        ..assignment = result.code,
    ),
  ];
}

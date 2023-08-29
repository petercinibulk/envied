import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

mixin Fields {
  Iterable<Field> buildField(FieldElement field, String value) {
    final String type = field.type.getDisplayString(withNullability: false);

    late final Expression? result;

    if (field.type.isDartCoreInt ||
        field.type.isDartCoreDouble ||
        field.type.isDartCoreNum) {
      try {
        result = literalNum(num.parse(value));
      } on FormatException {
        throw InvalidGenerationSourceError(
          'Type `$type` do not align up to value `$value`.',
          element: field,
        );
      }
    } else if (field.type.isDartCoreBool) {
      try {
        result = literalBool(bool.parse(value));
      } on FormatException {
        throw InvalidGenerationSourceError(
          'Type `$type` do not align up to value `$value`.',
          element: field,
        );
      }
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
                : field.type.getDisplayString(withNullability: false),
          )
          ..name = field.name
          ..assignment = Code(result.toString()),
      ),
    ];
  }
}

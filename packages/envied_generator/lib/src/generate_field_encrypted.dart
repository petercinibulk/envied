// ignore_for_file: deprecated_member_use

import 'dart:math' show Random;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
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
Iterable<Field> generateFieldsEncrypted(
  FieldElement field,
  String? value, {
  bool allowOptional = false,
  int? randomSeed,
  bool multipleAnnotations = false,
}) {
  final Random rand = randomSeed != null ? Random(randomSeed) : Random.secure();
  final String type = field.type.getDisplayString(withNullability: false);
  final String keyName = '_enviedkey${field.name}';
  final bool isNullable =
      allowOptional &&
      field.type.nullabilitySuffix == NullabilitySuffix.question;

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
        'Obfuscated envied can only handle types such as `int`, `double`, '
        '`num`, `bool`, `Uri`, `DateTime`, `Enum` and `String`. '
        'Type `$type` is not one of them.',
        element: field,
      );
    }

    return [
      Field(
        (FieldBuilder fieldBuilder) => fieldBuilder
          ..static = true
          ..modifier = FieldModifier.final$
          ..type = field.type is! DynamicType
              ? refer(field.type.getDisplayString(withNullability: true))
              : null
          ..name = field.name
          ..assignment = literalNull.code,
      ),
    ];
  }

  if (field.type.isDartCoreInt) {
    final int? parsed = int.tryParse(value);

    if (parsed == null) {
      throw InvalidGenerationSourceError(
        'Type `$type` does not align with value `$value`.',
        element: field,
      );
    }

    final int key = rand.nextInt(1 << 32);
    final int encValue = parsed ^ key;

    return [
      Field(
        (FieldBuilder fieldBuilder) => fieldBuilder
          ..static = true
          ..modifier = FieldModifier.final$
          ..type = refer('int')
          ..name = keyName
          ..assignment = literalNum(key).code,
      ),
      Field(
        (FieldBuilder fieldBuilder) => fieldBuilder
          ..static = true
          ..modifier = FieldModifier.final$
          ..type = TypeReference(
            (b) => b
              ..symbol = 'int'
              ..isNullable = isNullable,
          )
          ..name = field.name
          ..assignment = refer(
            keyName,
          ).operatorBitwiseXor(literalNum(encValue)).code,
      ),
    ];
  }

  if (field.type.isDartCoreBool) {
    final bool? parsed = bool.tryParse(value);

    if (parsed == null) {
      throw InvalidGenerationSourceError(
        'Type `$type` does not align with value `$value`.',
        element: field,
      );
    }

    final bool key = rand.nextBool();
    final bool encValue = parsed ^ key;

    return [
      Field(
        (FieldBuilder fieldBuilder) => fieldBuilder
          ..static = true
          ..modifier = FieldModifier.final$
          ..type = refer('bool')
          ..name = keyName
          ..assignment = literalBool(key).code,
      ),
      Field(
        (FieldBuilder fieldBuilder) => fieldBuilder
          ..static = true
          ..modifier = FieldModifier.final$
          ..type = TypeReference(
            (b) => b
              ..symbol = 'bool'
              ..isNullable = isNullable,
          )
          ..name = field.name
          ..assignment = refer(
            keyName,
          ).operatorBitwiseXor(literalBool(encValue)).code,
      ),
    ];
  }

  if (field.type.isDartCoreDouble ||
      field.type.isDartCoreNum ||
      field.type.isDartCoreUri ||
      field.type.isDartCoreDateTime ||
      field.type.isDartEnum ||
      field.type.isDartCoreString ||
      field.type is DynamicType) {
    if ((field.type.isDartCoreUri && Uri.tryParse(value) == null) ||
        (field.type.isDartCoreDateTime && DateTime.tryParse(value) == null) ||
        ((field.type.isDartCoreDouble || field.type.isDartCoreNum) &&
            num.tryParse(value) == null)) {
      throw InvalidGenerationSourceError(
        'Type `$type` does not align with value `$value`.',
        element: field,
      );
    }

    if (field.type.isDartEnum) {
      final EnumElement enumElement = field.type.element as EnumElement;

      if (!enumElement.valueNames.contains(value)) {
        throw InvalidGenerationSourceError(
          'Enumerated type `$type` does not contain value `$value`. '
          'Possible values are: ${enumElement.valueNames.map((el) => '`$el`').join(', ')}.',
          element: field,
        );
      }
    }

    late final String? symbol;
    late final Expression result;
    final List<int> parsed = value.codeUnits;
    final List<int> key = [
      for (int i = 0; i < parsed.length; i++) rand.nextInt(1 << 32),
    ];
    final List<int> encValue = [
      for (int i = 0; i < parsed.length; i++) parsed[i] ^ key[i],
    ];
    final String encName = '_envieddata${field.name}';
    final Expression stringExpression = refer('String').type.newInstanceNamed(
      'fromCharCodes',
      [
        TypeReference(
              (TypeReferenceBuilder typeBuilder) => typeBuilder
                ..symbol = 'List'
                ..types.add(refer('int')),
            ).type
            .newInstanceNamed(
              'generate',
              [
                refer(encName).property('length'),
                Method(
                  (MethodBuilder method) => method
                    ..lambda = true
                    ..requiredParameters.add(
                      Parameter(
                        (ParameterBuilder param) => param
                          ..name = 'i'
                          ..type = refer('int'),
                      ),
                    )
                    ..body = refer('i').code,
                ).closure,
              ],
              {'growable': literalFalse},
            )
            .property('map')
            .call([
              Method(
                (MethodBuilder methodBuilder) => methodBuilder
                  ..lambda = true
                  ..requiredParameters.add(
                    Parameter(
                      (ParameterBuilder paramBuilder) => paramBuilder
                        ..name = 'i'
                        ..type = refer('int'),
                    ),
                  )
                  ..body = refer(encName)
                      .index(refer('i'))
                      .operatorBitwiseXor(refer(keyName).index(refer('i')))
                      .code,
              ).closure,
            ]),
      ],
    );

    if (field.type.isDartCoreDouble || field.type.isDartCoreNum) {
      symbol = field.type.isDartCoreDouble ? 'double' : 'num';
      result = refer(symbol).type.newInstanceNamed('parse', [stringExpression]);
    } else if (field.type.isDartCoreUri) {
      symbol = 'Uri';
      result = refer('Uri').type.newInstanceNamed('parse', [stringExpression]);
    } else if (field.type.isDartCoreDateTime) {
      symbol = 'DateTime';
      result = refer(
        'DateTime',
      ).type.newInstanceNamed('parse', [stringExpression]);
    } else if (field.type.isDartEnum) {
      symbol = field.type.getDisplayString(withNullability: false);
      result = refer(
        symbol,
      ).type.property('values').property('byName').call([stringExpression]);
    } else {
      symbol = field.type is! DynamicType ? 'String' : null;
      result = stringExpression;
    }

    return [
      Field(
        (FieldBuilder fieldBuilder) => fieldBuilder
          ..static = true
          ..modifier = FieldModifier.constant
          ..type = TypeReference(
            (TypeReferenceBuilder typeBuilder) => typeBuilder
              ..symbol = 'List'
              ..types.add(refer('int')),
          )
          ..name = keyName
          ..assignment = literalList(key, refer('int')).code,
      ),
      Field(
        (FieldBuilder fieldBuilder) => fieldBuilder
          ..static = true
          ..modifier = FieldModifier.constant
          ..type = TypeReference(
            (TypeReferenceBuilder typeBuilder) => typeBuilder
              ..symbol = 'List'
              ..types.add(refer('int')),
          )
          ..name = encName
          ..assignment = literalList(encValue, refer('int')).code,
      ),
      Field(
        (FieldBuilder fieldBuilder) => fieldBuilder
          ..annotations.addAll([if (multipleAnnotations) refer('override')])
          ..static = !multipleAnnotations
          ..modifier = FieldModifier.final$
          ..type = field.type is! DynamicType
              ? TypeReference(
                  (TypeReferenceBuilder typeBuilder) => typeBuilder
                    ..symbol = symbol
                    ..isNullable = isNullable,
                )
              : null
          ..name = field.name
          ..assignment = result.code,
      ),
    ];
  }

  throw InvalidGenerationSourceError(
    'Obfuscated envied can only handle types such as `int`, `double`, '
    '`num`, `bool`, `Uri`, `DateTime` and `String`. '
    'Type `$type` is not one of them.',
    element: field,
  );
}

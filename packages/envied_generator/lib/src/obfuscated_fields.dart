import 'dart:math' show Random;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

mixin ObfuscatedFields {
  Iterable<Field> buildObfuscatedField(FieldElement field, String value) {
    final Random rand = Random.secure();
    final String type = field.type.getDisplayString(withNullability: false);
    final String keyName = '_enviedkey${field.name}';

    if (field.type.isDartCoreInt) {
      final int? parsed = int.tryParse(value);

      if (parsed == null) {
        throw InvalidGenerationSourceError(
          'Type `$type` does not align up to value `$value`.',
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
            ..type = refer('int')
            ..name = field.name
            ..assignment = Code('$keyName ^ $encValue'),
        ),
      ];
    }

    if (field.type.isDartCoreBool) {
      final bool? parsed = bool.tryParse(value);

      if (parsed == null) {
        throw InvalidGenerationSourceError(
          'Type `$type` does not align up to value `$value`.',
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
            ..type = refer('bool')
            ..name = field.name
            ..assignment = Code('$keyName ^ $encValue'),
        ),
      ];
    }

    if (field.type.isDartCoreString || field.type is DynamicType) {
      final List<int> parsed = value.codeUnits;
      final List<int> key = [
        for (int i = 0; i < parsed.length; i++) rand.nextInt(1 << 32)
      ];
      final List<int> encValue = [
        for (int i = 0; i < parsed.length; i++) parsed[i] ^ key[i]
      ];
      final String encName = '_envieddata${field.name}';

      return [
        Field(
          (FieldBuilder fieldBuilder) => fieldBuilder
            ..static = true
            ..modifier = FieldModifier.constant
            ..type = refer('List<int>')
            ..name = keyName
            ..assignment = literalList(key, refer('int')).code,
        ),
        Field(
          (FieldBuilder fieldBuilder) => fieldBuilder
            ..static = true
            ..modifier = FieldModifier.constant
            ..type = refer('List<int>')
            ..name = encName
            ..assignment = literalList(encValue, refer('int')).code,
        ),
        Field(
          (FieldBuilder fieldBuilder) => fieldBuilder
            ..static = true
            ..modifier = FieldModifier.final$
            ..type = refer(field.type is DynamicType ? '' : 'String')
            ..name = field.name
            ..assignment = refer('String').type.newInstanceNamed(
              'fromCharCodes',
              [
                refer('List<int>')
                    .type
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
                          ..body = Block.of([
                            refer(encName).index(refer('i')).code,
                            Code('^'),
                            refer(keyName).index(refer('i')).code,
                          ]),
                      ).closure,
                    ]),
              ],
            ).code,
        ),
      ];
    }

    throw InvalidGenerationSourceError(
      'Obfuscated envied can only handle types such as `int`, `bool` and `String`. '
      'Type `$type` is not one of them.',
      element: field,
    );
  }
}

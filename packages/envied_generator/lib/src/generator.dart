import 'dart:io' show Platform;
import 'dart:math' show Random;

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:envied/envied.dart';
import 'package:envied_generator/src/load_envs.dart';
import 'package:source_gen/source_gen.dart';

/// Generate code for classes annotated with the `@Envied()`.
///
/// Will throw an [InvalidGenerationSourceError] if the annotated
/// element is not a [classElement].
final class EnviedGenerator extends GeneratorForAnnotation<Envied> {
  const EnviedGenerator();

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final Element enviedEl = element;
    if (enviedEl is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@Envied` can only be used on classes.',
        element: enviedEl,
      );
    }

    final Envied config = Envied(
      path: annotation.read('path').literalValue as String?,
      requireEnvFile:
          annotation.read('requireEnvFile').literalValue as bool? ?? false,
      name: annotation.read('name').literalValue as String?,
      obfuscate: annotation.read('obfuscate').literalValue as bool,
    );

    final Map<String, String> envs = await loadEnvs(
      config.path,
      (String error) {
        if (config.requireEnvFile) {
          throw InvalidGenerationSourceError(
            error,
            element: enviedEl,
          );
        }
      },
    );

    return _buildEnvClass(
      annotation: annotation,
      classElement: enviedEl,
      config: config,
      envs: envs,
    );
  }

  static TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  static String _buildEnvClass({
    required ConstantReader annotation,
    required ClassElement classElement,
    required Envied config,
    required Map<String, String> envs,
  }) {
    final DartEmitter emitter = DartEmitter(useNullSafetySyntax: true);

    final Class cls = Class(
      (ClassBuilder classBuilder) => classBuilder
        ..modifier = ClassModifier.final$
        ..name = '_${config.name ?? classElement.name}'
        ..fields.addAll([
          for (FieldElement field in classElement.fields)
            if (_typeChecker(EnviedField).hasAnnotationOf(field))
              ..._buildFields(
                field: field,
                config: config,
                envs: envs,
              ),
        ]),
    );

    return DartFormatter().format(cls.accept(emitter).toString());
  }

  static List<Field> _buildFields({
    required FieldElement field,
    required Envied config,
    required Map<String, String> envs,
  }) {
    final DartObject? dartObject =
        _typeChecker(EnviedField).firstAnnotationOf(field);

    final ConstantReader reader = ConstantReader(dartObject);

    final String varName =
        reader.read('varName').literalValue as String? ?? field.name;

    final Object? defaultValue = reader.read('defaultValue').literalValue;

    late final String? varValue;

    if (envs.containsKey(varName)) {
      varValue = envs[varName];
    } else if (Platform.environment.containsKey(varName)) {
      varValue = Platform.environment[varName];
    } else {
      varValue = defaultValue?.toString();
    }

    if (varValue == null) {
      throw InvalidGenerationSourceError(
        'Environment variable not found for field `${field.name}`.',
        element: field,
      );
    }

    if (reader.read('obfuscate').literalValue as bool? ?? config.obfuscate) {
      return _encryptedField(field, varValue);
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
          ..assignment = _fieldAssignment(field, varValue!),
      ),
    ];
  }

  static Code _fieldAssignment(FieldElement field, String value) {
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

    return Code(result.toString());
  }

  static List<Field> _encryptedField(FieldElement field, String value) {
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
            ..assignment = Code(key.toString()),
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
            ..assignment = Code(key.toString()),
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
            ..assignment = Code(literalList(key, refer('int')).toString()),
        ),
        Field((FieldBuilder fieldBuilder) => fieldBuilder
          ..static = true
          ..modifier = FieldModifier.constant
          ..type = refer('List<int>')
          ..name = encName
          ..assignment = Code(literalList(encValue, refer('int')).toString())),
        Field(
          (FieldBuilder fieldBuilder) => fieldBuilder
            ..static = true
            ..modifier = FieldModifier.final$
            ..type = refer(field.type is DynamicType ? '' : 'String')
            ..name = field.name
            ..assignment = Code(
              'String.fromCharCodes(['
              '  for (int i = 0; i < $encName.length; i++) '
              '    $encName[i] ^ $keyName[i] '
              '])',
            ),
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

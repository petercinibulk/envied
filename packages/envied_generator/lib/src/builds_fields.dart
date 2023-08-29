import 'dart:io' show Platform;

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:envied/envied.dart';
import 'package:envied_generator/src/fields.dart';
import 'package:envied_generator/src/obfuscated_fields.dart';
import 'package:source_gen/source_gen.dart';

mixin BuildsFields implements Fields, ObfuscatedFields {
  Iterable<Field> buildFields({
    required FieldElement field,
    required Envied config,
    required Map<String, String> envs,
  }) {
    final DartObject? dartObject =
        TypeChecker.fromRuntime(EnviedField).firstAnnotationOf(field);

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

    return reader.read('obfuscate').literalValue as bool? ?? config.obfuscate
        ? buildObfuscatedField(field, varValue)
        : buildField(field, varValue);
  }
}

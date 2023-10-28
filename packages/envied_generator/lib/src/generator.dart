import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:envied/envied.dart';
import 'package:envied_generator/src/generate_field.dart';
import 'package:envied_generator/src/generate_field_encrypted.dart';
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
        log.warning(error);
        if (config.requireEnvFile) {
          throw InvalidGenerationSourceError(
            error,
            element: enviedEl,
          );
        }
      },
    );

    final DartEmitter emitter = DartEmitter(useNullSafetySyntax: true);

    final Class cls = Class(
      (ClassBuilder classBuilder) => classBuilder
        ..modifier = ClassModifier.final$
        ..name = '_${config.name ?? enviedEl.name}'
        ..fields.addAll([
          for (FieldElement field in enviedEl.fields)
            if (_typeChecker(EnviedField).hasAnnotationOf(field))
              ..._generateFields(
                field: field,
                config: config,
                envs: envs,
              ),
        ]),
    );

    return DartFormatter().format(cls.accept(emitter).toString());
  }

  static TypeChecker _typeChecker(Type type) => TypeChecker.fromRuntime(type);

  static Iterable<Field> _generateFields({
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

    return reader.read('obfuscate').literalValue as bool? ?? config.obfuscate
        ? generateFieldsEncrypted(field, varValue)
        : generateFields(field, varValue);
  }
}

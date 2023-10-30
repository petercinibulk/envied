import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
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
      allowOptionalFields:
          annotation.read('allowOptionalFields').literalValue as bool? ?? false,
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

    if (field.type is InvalidType) {
      throw InvalidGenerationSourceError(
        'Envied requires types to be explicitly declared. `${field.name}` does not declare a type.',
        element: field,
      );
    }

    final bool optional = reader.read('optional').literalValue as bool? ??
        config.allowOptionalFields;

    // Throw if value is null but the field is not nullable
    bool isNullable = field.type is DynamicType ||
        field.type.nullabilitySuffix == NullabilitySuffix.question;
    if (varValue == null && !(optional && isNullable)) {
      throw InvalidGenerationSourceError(
        'Environment variable not found for field `${field.name}`.',
        element: field,
      );
    }

    return reader.read('obfuscate').literalValue as bool? ?? config.obfuscate
        ? generateFieldsEncrypted(field, varValue, allowOptional: optional)
        : generateFields(field, varValue, allowOptional: optional);
  }
}

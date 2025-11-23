// ignore_for_file: deprecated_member_use

import 'dart:io' show Platform;

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:envied/envied.dart';
import 'package:envied_generator/src/build_options.dart';
import 'package:envied_generator/src/env_val.dart';
import 'package:envied_generator/src/generate_field.dart';
import 'package:envied_generator/src/generate_field_encrypted.dart';
import 'package:envied_generator/src/load_envs.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

/// Generate code for classes annotated with the `@Envied()`.
///
/// Will throw an [InvalidGenerationSourceError] if the annotated
/// element is not a [ClassElement2].
final class EnviedGenerator extends GeneratorForAnnotation<Envied> {
  const EnviedGenerator(this._buildOptions);

  final BuildOptions _buildOptions;

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@Envied` can only be used on classes.',
        element: element,
      );
    }

    final Iterable<ConstantReader> enviedAnnotations = element
        .metadata
        .annotations
        .where(
          (ElementAnnotation annotation) =>
              annotation.element?.displayName == 'Envied',
        )
        .map(
          (ElementAnnotation annotation) =>
              ConstantReader(annotation.computeConstantValue()),
        );

    final bool multipleAnnotations = enviedAnnotations.length > 1;

    final StringBuffer generatedClassesAltogether = StringBuffer();

    for (final ConstantReader reader in enviedAnnotations) {
      generatedClassesAltogether.writeln(
        await _generateClassForEnviedAnnotation(
          element: element,
          annotation: reader,
          buildStep: buildStep,
          multipleAnnotations: multipleAnnotations,
        ),
      );
    }

    final String? generatedFrom =
        _buildOptions.override == true && _buildOptions.path?.isNotEmpty == true
        ? _buildOptions.path
        : annotation.read('path').literalValue as String?;

    final String ignore =
        '// coverage:ignore-file\n'
        '// ignore_for_file: type=lint\n'
        '// generated_from: $generatedFrom';

    return '$ignore\n$generatedClassesAltogether';
  }

  Future<String> _generateClassForEnviedAnnotation({
    required ClassElement element,
    required ConstantReader annotation,
    required BuildStep buildStep,
    bool multipleAnnotations = false,
  }) async {
    final Envied config = Envied(
      path:
          _buildOptions.override == true &&
              _buildOptions.path?.isNotEmpty == true
          ? _buildOptions.path
          : annotation.read('path').literalValue as String?,
      requireEnvFile:
          annotation.read('requireEnvFile').literalValue as bool? ?? false,
      name: annotation.read('name').literalValue as String?,
      obfuscate: annotation.read('obfuscate').literalValue as bool,
      allowOptionalFields:
          annotation.read('allowOptionalFields').literalValue as bool? ?? false,
      environment:
          annotation.read('environment').literalValue as bool? ?? false,
      useConstantCase:
          annotation.read('useConstantCase').literalValue as bool? ?? false,
      interpolate: annotation.read('interpolate').literalValue as bool? ?? true,
      rawStrings: annotation.read('rawStrings').literalValue as bool? ?? false,
      randomSeed: annotation.read('randomSeed').literalValue as int?,
    );

    final Map<String, EnvVal> envs = await loadEnvs(config.path, (
      String error,
    ) {
      if (config.requireEnvFile) {
        throw InvalidGenerationSourceError(error, element: element);
      }
    });

    final DartEmitter emitter = DartEmitter(useNullSafetySyntax: true);

    final Class cls = Class(
      (ClassBuilder classBuilder) => classBuilder
        ..modifier = ClassModifier.final$
        ..name = '_${config.name ?? element.name}'
        ..implements.addAll([if (multipleAnnotations) refer(element.name!)])
        ..fields.addAll(
          element.fields
              .where(
                (FieldElement field) => _typeChecker(
                  EnviedField,
                  inPackage: 'envied',
                ).hasAnnotationOf(field),
              )
              .expand(
                (FieldElement field) => _generateFields(
                  field: field,
                  config: config,
                  envs: envs,
                  multipleAnnotations: multipleAnnotations,
                ),
              ),
        ),
    );

    return cls.accept(emitter).toString();
  }

  static TypeChecker _typeChecker(
    Type type, {
    String? inPackage,
    bool? inSdk,
  }) => TypeChecker.typeNamed(type, inPackage: inPackage, inSdk: inSdk);

  static Iterable<Field> _generateFields({
    required FieldElement field,
    required Envied config,
    required Map<String, EnvVal> envs,
    bool multipleAnnotations = false,
  }) {
    final DartObject? dartObject = _typeChecker(
      EnviedField,
      inPackage: 'envied',
    ).firstAnnotationOf(field);

    final ConstantReader reader = ConstantReader(dartObject);

    late String varName;

    final bool environment =
        reader.read('environment').literalValue as bool? ?? config.environment;

    final bool useConstantCase =
        reader.read('useConstantCase').literalValue as bool? ??
        config.useConstantCase;

    if (reader.read('varName').literalValue == null) {
      varName = useConstantCase ? field.name!.constantCase : field.name!;
    } else {
      varName = reader.read('varName').literalValue as String;
    }

    final Object? defaultValue = reader.read('defaultValue').literalValue;

    late final EnvVal? varValue;

    if (environment) {
      final String? envKey = envs[varName]?.raw;
      if (envKey == null) {
        throw InvalidGenerationSourceError(
          'Expected to find an .env entry with a key of `$varName` for field `${field.name}` but none was found.',
          element: field,
        );
      }
      final String? env = Platform.environment[envKey];
      if (env == null) {
        throw InvalidGenerationSourceError(
          'Expected to find an System environment variable named `$envKey` for field `${field.name}` but no value was found.',
          element: field,
        );
      }

      varValue = EnvVal(raw: env);
    } else if (envs.containsKey(varName)) {
      varValue = envs[varName];
    } else if (Platform.environment.containsKey(varName)) {
      varValue = EnvVal(raw: Platform.environment[varName]!);
    } else {
      varValue = defaultValue != null
          ? EnvVal(raw: defaultValue.toString())
          : null;
    }

    if (field.type is InvalidType) {
      throw InvalidGenerationSourceError(
        'Envied requires types to be explicitly declared. `${field.name}` does not declare a type.',
        element: field,
      );
    }

    final bool optional =
        reader.read('optional').literalValue as bool? ??
        config.allowOptionalFields;

    final bool interpolate =
        reader.read('interpolate').literalValue as bool? ?? config.interpolate;

    final bool rawString =
        reader.read('rawString').literalValue as bool? ?? config.rawStrings;

    // Throw if value is null but the field is not nullable
    bool isNullable =
        field.type is DynamicType ||
        field.type.nullabilitySuffix == NullabilitySuffix.question;
    if (varValue == null && !(optional && isNullable)) {
      throw InvalidGenerationSourceError(
        'Environment variable not found for field `${field.name}`.',
        element: field,
      );
    }

    return reader.read('obfuscate').literalValue as bool? ?? config.obfuscate
        ? generateFieldsEncrypted(
            field,
            interpolate ? varValue?.interpolated : varValue?.raw,
            allowOptional: optional,
            randomSeed:
                (reader.read('randomSeed').literalValue as int?) ??
                config.randomSeed,
            multipleAnnotations: multipleAnnotations,
          )
        : generateFields(
            field,
            interpolate ? varValue?.interpolated : varValue?.raw,
            allowOptional: optional,
            rawString: rawString,
            multipleAnnotations: multipleAnnotations,
          );
  }
}

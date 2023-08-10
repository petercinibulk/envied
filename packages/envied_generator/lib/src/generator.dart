import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:envied/envied.dart';
import 'package:envied_generator/src/generate_line.dart';
import 'package:envied_generator/src/generate_line_encrypted.dart';
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
    Element enviedEl = element;
    if (enviedEl is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@Envied` can only be used on classes.',
        element: enviedEl,
      );
    }

    final config = Envied(
      path: annotation.read('path').literalValue as String?,
      requireEnvFile:
          annotation.read('requireEnvFile').literalValue as bool? ?? false,
      name: annotation.read('name').literalValue as String?,
      obfuscate: annotation.read('obfuscate').literalValue as bool,
    );

    final envs = await loadEnvs(config.path, (error) {
      if (config.requireEnvFile) {
        throw InvalidGenerationSourceError(
          error,
          element: enviedEl,
        );
      }
    });

    TypeChecker enviedFieldChecker = TypeChecker.fromRuntime(EnviedField);

    final lines = enviedEl.fields.map((fieldEl) {
      if (enviedFieldChecker.hasAnnotationOf(fieldEl)) {
        DartObject? dartObject = enviedFieldChecker.firstAnnotationOf(fieldEl);
        ConstantReader reader = ConstantReader(dartObject);

        String varName =
            reader.read('varName').literalValue as String? ?? fieldEl.name;

        Object? defaultValue = reader.read('defaultValue').literalValue;

        String? varValue;
        if (envs.containsKey(varName)) {
          varValue = envs[varName];
        } else if (Platform.environment.containsKey(varName)) {
          varValue = Platform.environment[varName];
        } else {
          if (defaultValue != null) {
            varValue = defaultValue.toString();
          }
        }

        final bool obfuscate =
            reader.read('obfuscate').literalValue as bool? ?? config.obfuscate;

        return (obfuscate ? generateLineEncrypted : generateLine)(
          fieldEl,
          varValue,
        );
      } else {
        return '';
      }
    });

    return '''
    final class _${config.name ?? enviedEl.name} {
      ${lines.toList().join()}
    }
    ''';
  }
}

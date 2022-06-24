import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:envied/envied.dart';
import 'package:envied_generator/src/generate_line.dart';
import 'package:envied_generator/src/load_envs.dart';
import 'package:source_gen/source_gen.dart';

/// Generate code for classes annotated with the `@Envied()`.
///
/// Will throw an [InvalidGenerationSourceError] if the annotated
/// element is not a [classElement].
class EnviedGenerator extends GeneratorForAnnotation<Envied> {
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
    );

    final envs = await loadEnvs(config.path, (error) {
      throw InvalidGenerationSourceError(
        error,
        element: enviedEl,
      );
    });

    final lines = enviedEl.fields.map((field) {
      if (enviedFieldChecker.hasAnnotationOf(field)) {
        String envName = _getEnvName(field);
        return generateLine(
          field,
          envs.containsKey(envName) ? envs[envName] : null,
        );
      } else {
        return '';
      }
    });

    return '''
    class _${enviedEl.name} {
      ${lines.toList().join()}
    }
    ''';
  }

  static const enviedFieldChecker = TypeChecker.fromRuntime(EnviedField);

  String _getEnvName(FieldElement fieldEl) {
    DartObject? dartObject = enviedFieldChecker.firstAnnotationOf(fieldEl);
    ConstantReader reader = ConstantReader(dartObject);
    return reader.read('varName').literalValue as String? ?? fieldEl.name;
  }
}

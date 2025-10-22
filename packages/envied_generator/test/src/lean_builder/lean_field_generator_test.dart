import 'package:envied/envied.dart';
import 'package:envied_generator/src/env_val.dart';
import 'package:envied_generator/src/lean_builder/lean_field_generator.dart';
import 'package:test/test.dart';

void main() {
  group('LeanFieldGenerator', () {
    test('creates generator with config', () {
      final generator = LeanFieldGenerator(
        config: const Envied(),
        envs: {},
        multipleAnnotations: false,
      );

      expect(generator.config, isA<Envied>());
      expect(generator.envs, isEmpty);
      expect(generator.multipleAnnotations, false);
    });

    test('creates generator with obfuscate and randomSeed', () {
      final generator = LeanFieldGenerator(
        config: const Envied(obfuscate: true, randomSeed: 12345),
        envs: {},
      );

      expect(generator.config.obfuscate, true);
      expect(generator.config.randomSeed, 12345);
    });

    test('creates generator with multiple annotations', () {
      final generator = LeanFieldGenerator(
        config: const Envied(),
        envs: {},
        multipleAnnotations: true,
      );

      expect(generator.multipleAnnotations, true);
    });

    test('creates generator with environment variables', () {
      final envs = {
        'API_KEY': EnvVal(raw: 'test_key'),
        'PORT': EnvVal(raw: '8080'),
      };

      final generator = LeanFieldGenerator(config: const Envied(), envs: envs);

      expect(generator.envs, hasLength(2));
      expect(generator.envs['API_KEY']?.raw, 'test_key');
      expect(generator.envs['PORT']?.raw, '8080');
    });

    test('creates generator with interpolated values', () {
      final envs = {
        'BASE_URL': EnvVal(
          raw: 'https://\${HOST}',
          interpolated: 'https://example.com',
        ),
      };

      final generator = LeanFieldGenerator(config: const Envied(), envs: envs);

      expect(generator.envs['BASE_URL']?.raw, 'https://\${HOST}');
      expect(generator.envs['BASE_URL']?.interpolated, 'https://example.com');
    });

    // Note: Full integration tests for generateForField would require
    // mock FieldElement objects which are complex to create.
    // These are covered in integration tests instead.
  });

  group('EnvVal', () {
    test('creates with raw value', () {
      final envVal = EnvVal(raw: 'test');
      expect(envVal.raw, 'test');
      expect(envVal.interpolated, 'test');
    });

    test('creates with raw and interpolated values', () {
      final envVal = EnvVal(raw: '\${VAR}', interpolated: 'value');
      expect(envVal.raw, '\${VAR}');
      expect(envVal.interpolated, 'value');
    });
  });
}

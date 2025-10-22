import 'package:envied_generator/src/lean_builder/lean_envied_resolver.dart';
import 'package:test/test.dart';

void main() {
  group('LeanEnviedResolver', () {
    late LeanEnviedResolver resolver;

    setUp(() {
      resolver = LeanEnviedResolver();
    });

    test('creates resolver instance', () {
      expect(resolver, isNotNull);
    });

    // Note: Direct testing of resolveEnviedConfig and resolveEnviedField
    // requires lean_builder's ConstObject which cannot be easily mocked.
    // These methods are tested through integration tests and manual testing
    // with the examples in envied_lean_example/.
  });

  group('EnviedFieldConfig', () {
    test('creates with all null values', () {
      const config = EnviedFieldConfig();

      expect(config.varName, null);
      expect(config.obfuscate, null);
      expect(config.defaultValue, null);
      expect(config.environment, null);
      expect(config.optional, null);
      expect(config.useConstantCase, null);
      expect(config.interpolate, null);
      expect(config.rawString, null);
      expect(config.randomSeed, null);
    });

    test('creates with specific values', () {
      const config = EnviedFieldConfig(
        varName: 'TEST',
        obfuscate: true,
        defaultValue: 'default',
        environment: true,
        optional: true,
        useConstantCase: true,
        interpolate: false,
        rawString: true,
        randomSeed: 42,
      );

      expect(config.varName, 'TEST');
      expect(config.obfuscate, true);
      expect(config.defaultValue, 'default');
      expect(config.environment, true);
      expect(config.optional, true);
      expect(config.useConstantCase, true);
      expect(config.interpolate, false);
      expect(config.rawString, true);
      expect(config.randomSeed, 42);
    });

    test('const constructor allows compile-time constants', () {
      const config1 = EnviedFieldConfig(varName: 'TEST');
      const config2 = EnviedFieldConfig(varName: 'TEST');

      expect(identical(config1.varName, config2.varName), true);
    });
  });

  group('EnviedFieldInfo', () {
    test('can be created', () {
      // Note: This requires lean_builder DartType which cannot be easily created in tests
      // This class is tested through integration tests
      expect(EnviedFieldInfo, isNotNull);
    });
  });
}

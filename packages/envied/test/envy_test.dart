import 'package:envied/envied.dart';
import 'package:test/test.dart';

void main() {
  group('Envied Test Group', () {
    test('Empty constructor', () {
      final envied = Envied();
      expect(envied.path, '.env');
      expect(envied.requireEnvFile, false);
      expect(envied.obfuscate, false);
      expect(envied.useConstantCase, isFalse);
    });

    test('Specified path', () {
      final envied = Envied(path: '.env.test');
      expect(envied.path, '.env.test');
    });

    test('Specified useConstantCase', () {
      final envied = Envied(useConstantCase: true);
      expect(envied.useConstantCase, isTrue);
    });

    test('Specified requireEnvFile', () {
      final envied = Envied(requireEnvFile: true);
      expect(envied.requireEnvFile, true);
    });

    test('Specified name', () {
      final envied = Envied(name: 'Foo');
      expect(envied.name, 'Foo');
    });

    test('Specified obfuscate', () {
      final envied = Envied(obfuscate: true);
      expect(envied.obfuscate, true);
    });

    test('Specified randomSeed', () {
      final envied = Envied(randomSeed: 123);
      expect(envied.randomSeed, 123);
    });
  });

  group('EnviedField Test Group', () {
    test('Empty constructor', () {
      final enviedField = EnviedField();
      expect(enviedField.varName, null);
      expect(enviedField.obfuscate, null);
      expect(enviedField.optional, null);
      expect(enviedField.useConstantCase, null);
    });

    test('Specified path', () {
      final enviedField = EnviedField(varName: 'test');
      expect(enviedField.varName, 'test');
    });

    test('Specified obfuscate', () {
      final enviedField = EnviedField(obfuscate: true);
      expect(enviedField.obfuscate, isTrue);
    });

    test('Specified optional', () {
      final enviedField = EnviedField(optional: true);
      expect(enviedField.optional, isTrue);
    });

    test('Specified useConstantCase', () {
      final enviedField = EnviedField(useConstantCase: true);
      expect(enviedField.useConstantCase, isTrue);
    });

    test('Specified randomSeed', () {
      final enviedField = EnviedField(randomSeed: 123);
      expect(enviedField.randomSeed, 123);
    });
  });

  group('EnviedField Test Group with defaultValue', () {
    test('Empty constructor', () {
      final enviedField = EnviedField();
      expect(enviedField.varName, null);
      expect(enviedField.obfuscate, null);
      expect(enviedField.defaultValue, null);
    });

    test('Specified path', () {
      final enviedField = EnviedField(varName: 'test');
      expect(enviedField.varName, 'test');
    });

    test('Specified obfuscate', () {
      final enviedField = EnviedField(obfuscate: true);
      expect(enviedField.obfuscate, true);
    });

    test('Specified defaultValue as null value', () {
      final enviedField = EnviedField(defaultValue: null);
      expect(enviedField.defaultValue, null);
    });

    test('Specified defaultValue as String', () {
      final enviedField = EnviedField(defaultValue: 'test');
      expect(enviedField.defaultValue, 'test');
    });

    test('Specified defaultValue as num', () {
      final enviedField = EnviedField(defaultValue: 0);
      expect(enviedField.defaultValue, 0);
    });

    test('Specified defaultValue as double', () {
      final enviedField = EnviedField(defaultValue: 0.0);
      expect(enviedField.defaultValue, 0.0);
    });

    test('Specified defaultValue as bool', () {
      final enviedField = EnviedField(defaultValue: true);
      expect(enviedField.defaultValue, true);
    });

    test('Specified defaultValue with obfuscate', () {
      final enviedField = EnviedField(defaultValue: 'test', obfuscate: true);
      expect(enviedField.defaultValue, 'test');
      expect(enviedField.obfuscate, true);
    });
  });
}

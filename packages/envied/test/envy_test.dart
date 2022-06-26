import 'package:envied/envied.dart';
import 'package:test/test.dart';

void main() {
  group('Envied Test Group', () {
    test('Empty constructor', () {
      final envied = Envied();
      expect(envied.path, '.env');
    });

    test('Specified path', () {
      final envied = Envied(path: '.env.test');
      expect(envied.path, '.env.test');
    });

    test('Specified requireEnvFile', () {
      final envied = Envied(requireEnvFile: true);
      expect(envied.requireEnvFile, true);
    });
  });

  group('EnviedField Test Group', () {
    test('Empty constructor', () {
      final enviedField = EnviedField();
      expect(enviedField.varName, null);
    });

    test('Specified path', () {
      final enviedField = EnviedField(varName: 'test');
      expect(enviedField.varName, 'test');
    });
  });
}

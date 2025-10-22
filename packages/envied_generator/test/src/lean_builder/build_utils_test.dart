import 'package:envied_generator/src/lean_builder/build_utils.dart';
import 'package:lean_builder/builder.dart';
import 'package:test/test.dart';

void main() {
  group('ErrorMessages', () {
    test('typeNotDeclared returns correct message', () {
      final message = ErrorMessages.typeNotDeclared('apiKey');
      expect(
        message,
        'Envied requires types to be explicitly declared. `apiKey` does not declare a type.',
      );
    });

    test('typeValueMismatch returns correct message', () {
      final message = ErrorMessages.typeValueMismatch('int', 'abc');
      expect(message, 'Type `int` does not align with value `abc`.');
    });

    test('envVarNotFound returns correct message', () {
      final message = ErrorMessages.envVarNotFound('apiKey');
      expect(message, 'Environment variable not found for field `apiKey`.');
    });

    test('envEntryMissing returns correct message', () {
      final message = ErrorMessages.envEntryMissing('API_KEY', 'apiKey');
      expect(
        message,
        'Expected to find an .env entry with a key of `API_KEY` for field `apiKey` but none was found.',
      );
    });

    test('systemEnvMissing returns correct message', () {
      final message = ErrorMessages.systemEnvMissing('PROD_API_KEY', 'apiKey');
      expect(
        message,
        'Expected to find a System environment variable named `PROD_API_KEY` for field `apiKey` but no value was found.',
      );
    });

    test('unsupportedType returns correct message', () {
      final message = ErrorMessages.unsupportedType('Map');
      expect(
        message,
        'Envied can only handle types such as `int`, `double`, `num`, `bool`, `Uri`, `DateTime`, `Enum` and `String`. Type `Map` is not one of them.',
      );
    });

    test('unsupportedType with obfuscated returns correct message', () {
      final message = ErrorMessages.unsupportedType('Map', obfuscated: true);
      expect(
        message,
        'Obfuscated envied can only handle types such as `int`, `double`, `num`, `bool`, `Uri`, `DateTime`, `Enum` and `String`. Type `Map` is not one of them.',
      );
    });
  });

  group('throwIf', () {
    test('throws when condition is true', () {
      expect(
        () => throwIf(true, 'Test error'),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });

    test('does not throw when condition is false', () {
      expect(() => throwIf(false, 'Test error'), returnsNormally);
    });
  });

  group('throwError', () {
    test('throws InvalidGenerationSourceError', () {
      expect(
        () => throwError('Test error'),
        throwsA(isA<InvalidGenerationSourceError>()),
      );
    });
  });
}

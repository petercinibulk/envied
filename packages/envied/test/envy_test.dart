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
  });
}

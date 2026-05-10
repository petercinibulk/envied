import 'package:envied_generator/src/build_options.dart';
import 'package:test/test.dart';

void main() {
  group('BuildOptions', () {
    test('parses pathOverrides', () {
      final BuildOptions options = BuildOptions.fromMap(<String, dynamic>{
        'pathOverrides': <String, dynamic>{
          'ProductionEnv': '.env.production',
          'DebugEnv': '.env.debug',
        },
      });

      expect(options.pathOverrides, <String, String>{
        'ProductionEnv': '.env.production',
        'DebugEnv': '.env.debug',
      });
    });

    test('throws when pathOverrides is not a map', () {
      expect(
        () => BuildOptions.fromMap(<String, dynamic>{
          'pathOverrides': '.env.production',
        }),
        throwsArgumentError,
      );
    });

    test('throws when pathOverrides contains non-string values', () {
      expect(
        () => BuildOptions.fromMap(<String, dynamic>{
          'pathOverrides': <String, dynamic>{'ProductionEnv': 1},
        }),
        throwsArgumentError,
      );
    });

    test('throws when pathOverrides contains non-string keys', () {
      expect(
        () => BuildOptions.fromMap(<String, dynamic>{
          'pathOverrides': <dynamic, String>{1: '.env.production'},
        }),
        throwsArgumentError,
      );
    });
  });
}

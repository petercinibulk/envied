import 'package:envied_generator/envied_generator.dart';
import 'package:envied_generator/src/build_options.dart';
import 'package:source_gen_test/source_gen_test.dart';

Future<void> main() async {
  // for annotated elements
  initializeBuildLogTracking();

  // print(Platform.environment['SYSTEM_VAR']);

  testAnnotatedElements(
    await initializeLibraryReaderForDirectory(
      'test/src',
      'generator_tests.dart',
    ),
    EnviedGenerator(const BuildOptions()),
  );

  testAnnotatedElements(
    await initializeLibraryReaderForDirectory(
      'test/src',
      'generator_tests_with_path_override.dart',
    ),
    EnviedGenerator(
      const BuildOptions(
        path: 'test/.env.example_with_path_override',
        override: true,
      ),
    ),
  );

  testAnnotatedElements(
    await initializeLibraryReaderForDirectory(
      'test/src',
      'generator_tests_with_inheritance.dart',
    ),
    EnviedGenerator(const BuildOptions()),
  );

  testAnnotatedElements(
    await initializeLibraryReaderForDirectory(
      'test/src',
      'generator_tests_with_path_overrides.dart',
    ),
    EnviedGenerator(
      const BuildOptions(
        path: 'test/.env.path_overrides_global',
        pathOverrides: <String, String>{
          'ProductionEnv': 'test/.env.path_overrides_production',
          'DebugEnv': 'test/.env.path_overrides_debug',
          'test/.env.path_overrides_annotation':
              'test/.env.path_overrides_fallback',
        },
        override: true,
      ),
    ),
  );

  testAnnotatedElements(
    await initializeLibraryReaderForDirectory(
      'test/src',
      'generator_tests_with_path_overrides_disabled.dart',
    ),
    EnviedGenerator(
      const BuildOptions(
        path: 'test/.env.path_overrides_global',
        pathOverrides: <String, String>{
          'ProductionEnv': 'test/.env.path_overrides_production',
          'test/.env.path_overrides_annotation':
              'test/.env.path_overrides_fallback',
        },
        override: false,
      ),
    ),
  );
}

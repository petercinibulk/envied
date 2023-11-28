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
    EnviedGenerator(
      const BuildOptions(),
    ),
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
}

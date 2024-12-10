// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'package:envied/envied.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.example_with_path_override
final class _EnvWithPathOverride0 {}
''')
@Envied()
abstract class EnvWithPathOverride0 {}

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.example_with_path_override
final class _EnvWithPathOverride1 {}
''')
@Envied(requireEnvFile: true)
abstract class EnvWithPathOverride1 {}

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.example_with_path_override
final class _EnvWithPathOverride2 {
  static const String foo = 'bar';

  static const String baz = 'qux';

  static const String bad = r'unescaped$';
}
''')
@Envied()
abstract class EnvWithPathOverride2 {
  @EnviedField()
  static const String? foo = null;
  @EnviedField()
  static const String? baz = null;
  @EnviedField(rawString: true)
  static const String? bad = null;
}

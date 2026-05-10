// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'package:envied/envied.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.path_overrides_annotation
final class _ProductionEnv {
  static const String value = 'annotation';
}
''')
@Envied(path: 'test/.env.path_overrides_annotation', name: 'ProductionEnv')
abstract class EnvWithPathOverridesDisabled {
  @EnviedField()
  static const String? value = null;
}

// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'package:envied/envied.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.path_overrides_production, test/.env.path_overrides_debug
final class _ProductionEnv implements EnvWithPathOverridesByName {
  @override
  final String value = 'production';
}

final class _DebugEnv implements EnvWithPathOverridesByName {
  @override
  final String value = 'debug';
}
''')
@Envied(path: 'test/.env.path_overrides_annotation', name: 'ProductionEnv')
@Envied(path: 'test/.env.path_overrides_annotation', name: 'DebugEnv')
abstract class EnvWithPathOverridesByName {
  @EnviedField()
  final String? value = null;
}

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.path_overrides_fallback
final class _PathFallbackEnv {
  static const String value = 'fallback';
}
''')
@Envied(path: 'test/.env.path_overrides_annotation', name: 'PathFallbackEnv')
abstract class EnvWithPathOverridesByPath {
  @EnviedField()
  static const String? value = null;
}

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.path_overrides_global
final class _GlobalFallbackEnv {
  static const String value = 'global';
}
''')
@Envied(path: 'test/.env.path_overrides_not_used', name: 'GlobalFallbackEnv')
abstract class EnvWithPathOverridesGlobalFallback {
  @EnviedField()
  static const String? value = null;
}

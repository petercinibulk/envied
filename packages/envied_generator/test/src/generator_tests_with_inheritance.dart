// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'package:envied/envied.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.inheritance_defaults, test/.env.inheritance_middle, test/.env.inheritance_child
final class _EnvInheritance {
  static const String baseValue = 'base';

  static const String middleValue = 'middle';

  static const String childValue = 'child';

  static const String overrideValue = 'child';

  static const String interpolatedValue = 'base-child';

  static const String interpolatedOverrideValue = 'child';

  static const String duplicateValue = 'child-first';
}
''')
@Envied(
  path: 'test/.env.inheritance_child',
  inheritFrom: [
    'test/.env.inheritance_defaults',
    'test/.env.inheritance_middle',
  ],
)
abstract class EnvInheritance {
  @EnviedField()
  static const String? baseValue = null;
  @EnviedField()
  static const String? middleValue = null;
  @EnviedField()
  static const String? childValue = null;
  @EnviedField()
  static const String? overrideValue = null;
  @EnviedField()
  static const String? interpolatedValue = null;
  @EnviedField()
  static const String? interpolatedOverrideValue = null;
  @EnviedField()
  static const String? duplicateValue = null;
}

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.inheritance_missing, test/.env.inheritance_child
final class _EnvInheritanceWithMissingOptional {
  static const String childValue = 'child';
}
''')
@Envied(
  path: 'test/.env.inheritance_child',
  inheritFrom: ['test/.env.inheritance_missing'],
)
abstract class EnvInheritanceWithMissingOptional {
  @EnviedField()
  static const String? childValue = null;
}

@ShouldThrow(
  "Environment variable file doesn't exist at `test/.env.inheritance_missing`.",
)
@Envied(
  path: 'test/.env.inheritance_child',
  inheritFrom: ['test/.env.inheritance_missing'],
  requireEnvFile: true,
)
abstract class EnvInheritanceWithMissingRequired {}

@ShouldGenerate(r'''
// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: test/.env.inheritance_defaults, test/.env.inheritance_child, test/.env.inheritance_alt_defaults, test/.env.inheritance_alt_child
final class _DevelopmentEnv implements EnvInheritanceMultiple {
  @override
  final String baseValue = 'base';

  @override
  final String sharedValue = 'child';
}

final class _ProductionEnv implements EnvInheritanceMultiple {
  @override
  final String baseValue = 'alt-child';

  @override
  final String sharedValue = 'alt-child';
}
''')
@Envied(
  path: 'test/.env.inheritance_child',
  inheritFrom: ['test/.env.inheritance_defaults'],
  name: 'DevelopmentEnv',
)
@Envied(
  path: 'test/.env.inheritance_alt_child',
  inheritFrom: ['test/.env.inheritance_alt_defaults'],
  name: 'ProductionEnv',
)
abstract class EnvInheritanceMultiple {
  @EnviedField()
  final String? baseValue = null;
  @EnviedField()
  final String? sharedValue = null;
}

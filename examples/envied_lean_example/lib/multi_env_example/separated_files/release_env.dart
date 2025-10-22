import 'package:envied/envied.dart';
import 'package:envied_lean_example/example_enum.dart';
import 'package:envied_lean_example/multi_env_example/app_env_fields.dart';

import 'app_env.dart';

part 'release_env.g.dart';

@Envied(name: 'Env', path: '.env')
final class ReleaseEnv implements AppEnv, AppEnvFields {
  ReleaseEnv();

  @override
  @EnviedField(varName: 'KEY1')
  final String key1 = _Env.key1;

  @override
  @EnviedField(varName: 'KEY2')
  final String key2 = _Env.key2;

  @override
  @EnviedField()
  final String key3 = _Env.key3;

  @override
  @EnviedField()
  final int key4 = _Env.key4;

  @override
  @EnviedField()
  final bool key5 = _Env.key5;

  @override
  @EnviedField()
  final Uri key6 = _Env.key6;

  @override
  @EnviedField()
  final DateTime key7 = _Env.key7;

  @override
  @EnviedField()
  final ExampleEnum key8 = _Env.key8;

  @override
  @EnviedField(rawString: true)
  final String key9 = _Env.key9;
}

import 'package:envied/envied.dart';

import 'app_env.dart';
import 'app_env_fields.dart';

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
  @EnviedField(varName: 'KEY3')
  final String key3 = _Env.key3;
  @override
  @EnviedField(varName: 'KEY4')
  final int key4 = _Env.key4;
  @override
  @EnviedField(varName: 'KEY5')
  final bool key5 = _Env.key5;
  @override
  @EnviedField(varName: 'KEY6')
  final Uri key6 = _Env.key6;
  @override
  @EnviedField(varName: 'KEY7')
  final DateTime key7 = _Env.key7;
  @EnviedField(varName: 'TEST_KEY')
  static const String testKey = _Env.testKey;
}

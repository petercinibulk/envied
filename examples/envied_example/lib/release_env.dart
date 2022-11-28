import 'package:envied/envied.dart';

import 'app_env.dart';
import 'app_env_fields.dart';

part 'release_env.g.dart';

@Envied(name: 'Env', path: '.env')
class ReleaseEnv implements AppEnv, AppEnvFields {
  const ReleaseEnv();

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
}

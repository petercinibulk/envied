import 'package:envied/envied.dart';

part 'release_env.g.dart';

@Envied(name: 'Env', path: '.env')
abstract class ReleaseEnv implements EnvFields {
  @override
  @EnviedField(varName: 'KEY1')
  final String key1 = _Env.key1;
  @override
  @EnviedField(varName: 'KEY2')
  final String key2 = _Env.key2;
}
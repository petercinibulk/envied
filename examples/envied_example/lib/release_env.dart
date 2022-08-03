import 'package:envied/envied.dart';
import './app_env.dart';

part 'release_env.g.dart';

@Envied(name: 'Env', path: '.env')
class ReleaseEnv implements AppEnv {
  const ReleaseEnv();

  @override
  @EnviedField(varName: 'KEY1')
  final String key1 = _Env.key1;
  @override
  @EnviedField(varName: 'KEY2')
  final String key2 = _Env.key2;
}

import 'package:envied/envied.dart';
import './app_env.dart';

part 'debug_env.g.dart';

@Envied(name: 'Env', path: '.env_debug')
class DebugEnv implements AppEnv {
  const DebugEnv();

  @override
  @EnviedField(varName: 'KEY1')
  final String key1 = _Env.key1;
  @override
  @EnviedField(varName: 'KEY2')
  final String key2 = _Env.key2;
}

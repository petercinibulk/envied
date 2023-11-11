import 'package:envied/envied.dart';

part 'constant_case_env.g.dart';

@Envied(path: '.env', useConstantCase: true)
final class ConstantCaseEnv {
  @EnviedField()
  static const String key1 = _ConstantCaseEnv.key1;
  @EnviedField()
  static const String key2 = _ConstantCaseEnv.key2;
}

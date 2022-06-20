// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(envName: 'KEY1')
  static const key1 = _Env.key1;
  @EnviedField(envName: 'KEY2')
  static const key2 = _Env.key2;
}

// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'KEY1')
  static const String key1 = _Env.key1;
  @EnviedField(varName: 'KEY2')
  static const String key2 = _Env.key2;
  @EnviedField()
  static const String key3 = _Env.key3;
  @EnviedField()
  static const int key4 = _Env.key4;
  @EnviedField()
  static const bool key5 = _Env.key5;
}

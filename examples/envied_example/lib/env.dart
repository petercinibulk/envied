// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'KEY1')
  static const key1 = _Env.key1;
  @EnviedField(varName: 'KEY2')
  static const key2 = _Env.key2;
  @Default('test_')
  @EnviedField()
  static const String key3 = _Env.key3;
  @Default(0)
  @EnviedField()
  static const int key4 = _Env.key4;
  @Default(true)
  @EnviedField()
  static const bool key5 = _Env.key5;
}

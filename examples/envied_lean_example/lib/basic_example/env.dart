// lib/env.dart
import 'package:envied/envied.dart';
import 'package:envied_lean_example/example_enum.dart';

part 'env.g.dart';

@Envied(requireEnvFile: true)
final class Env {
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

  @EnviedField()
  static final Uri key6 = _Env.key6;

  @EnviedField()
  static final DateTime key7 = _Env.key7;

  @EnviedField()
  static final ExampleEnum key8 = _Env.key8;

  @EnviedField(rawString: true)
  static final String key9 = _Env.key9;
}

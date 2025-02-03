// lib/env.dart
import 'package:envied/envied.dart';
import 'package:example/example_enum.dart';

import 'app_env_fields.dart';

part 'envs.env.g.dart';

@Envied(
  path: '.env_debug',
  name: 'Dev',
  allowOptionalFields: true,
  interpolate: false,
  obfuscate: false,
  requireEnvFile: true,
  rawStrings: true,
  useConstantCase: false,
  randomSeed: 1,
)
@Envied(path: '.env', name: 'Prod')
final class Envs implements AppEnvFields {
  /// NOTE: This is here just as an example!
  ///
  /// In a Flutter app you would normally import this like so
  /// import 'package:flutter/foundation.dart';
  static const bool kDebugMode = true;

  factory Envs() => _instance;

  static final Envs _instance = kDebugMode ? _Dev() : _Prod();

  @override
  @EnviedField(varName: 'KEY1')
  final String key1 = _instance.key1;

  @override
  @EnviedField(varName: 'KEY2')
  final String key2 = _instance.key2;

  @override
  @EnviedField()
  final String key3 = _instance.key3;

  @override
  @EnviedField()
  final int key4 = _instance.key4;

  @override
  @EnviedField()
  final bool key5 = _instance.key5;

  @override
  @EnviedField()
  final Uri key6 = _instance.key6;

  @override
  @EnviedField()
  final DateTime key7 = _instance.key7;

  @override
  @EnviedField()
  final ExampleEnum key8 = _instance.key8;

  @override
  @EnviedField(rawString: true)
  final String key9 = _instance.key9;
}

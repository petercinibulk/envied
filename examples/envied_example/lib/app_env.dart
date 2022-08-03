import './app_env_fields.dart';
import './debug_env.dart';
import './release_env.dart';

abstract class AppEnv implements AppEnvFields {
  /// NOTE: This is here just as an example!
  ///
  /// In a Flutter app you would normally import this like so
  /// import 'package:flutter/foundation.dart';
  static const kDebugMode = true;

  factory AppEnv() => _instance;

  static const AppEnv _instance = kDebugMode ? DebugEnv() : ReleaseEnv();
}

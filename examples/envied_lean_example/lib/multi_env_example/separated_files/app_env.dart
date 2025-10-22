import 'package:envied_lean_example/multi_env_example/app_env_fields.dart';

import 'debug_env.dart';
import 'release_env.dart';

abstract interface class AppEnv implements AppEnvFields {
  /// NOTE: This is here just as an example!
  ///
  /// In a Flutter app you would normally import this like so
  /// import 'package:flutter/foundation.dart';
  static const bool kDebugMode = true;

  factory AppEnv() => _instance;

  static final AppEnv _instance = kDebugMode ? DebugEnv() : ReleaseEnv();
}

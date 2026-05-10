import 'dart:io' show File;

import 'package:envied_generator/src/env_val.dart';
import 'package:envied_generator/src/parser.dart';

/// Load the environment variables from the supplied [path],
/// using the `dotenv` parser.
///
/// If file doesn't exist, an error will be thrown through the
/// [onError] function.
Future<Map<String, EnvVal>> loadEnvs(
  String path,
  void Function(String) onError,
) => loadEnvsFromPaths(<String>[path], onError);

/// Load and merge environment variables from [paths].
///
/// Files are parsed in order. Later files override earlier files, while
/// duplicate keys within a single file keep the first parsed value.
Future<Map<String, EnvVal>> loadEnvsFromPaths(
  Iterable<String> paths,
  void Function(String) onError,
) async {
  final Map<String, EnvVal> envs = <String, EnvVal>{};

  for (final String path in paths) {
    envs.addAll(await _loadEnv(path, onError, env: envs));
  }

  return envs;
}

Future<Map<String, EnvVal>> _loadEnv(
  String path,
  void Function(String) onError, {
  required Map<String, EnvVal> env,
}) async {
  final File file = File.fromUri(Uri.file(path));

  final List<String> lines = [];
  if (await file.exists()) {
    lines.addAll(await file.readAsLines());
  } else {
    onError("Environment variable file doesn't exist at `$path`.");
  }

  return Parser.parse(lines, env: env);
}

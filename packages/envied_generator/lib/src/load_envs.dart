import 'dart:convert' show LineSplitter;
import 'dart:io' show File;

import 'package:build/build.dart';
import 'package:envied_generator/src/env_val.dart';
import 'package:envied_generator/src/parser.dart';

/// Load the environment variables from the supplied [path],
/// using the `dotenv` parser.
///
/// If file doesn't exist, an error will be thrown through the
/// [onError] function.
Future<Map<String, EnvVal>> loadEnvs(
  String path,
  void Function(String) onError, {
  BuildStep? buildStep,
}) => loadEnvsFromPaths(<String>[path], onError, buildStep: buildStep);

/// Load and merge environment variables from [paths].
///
/// Files are parsed in order. Later files override earlier files, while
/// duplicate keys within a single file keep the first parsed value.
Future<Map<String, EnvVal>> loadEnvsFromPaths(
  Iterable<String> paths,
  void Function(String) onError, {
  BuildStep? buildStep,
}) async {
  final Map<String, EnvVal> envs = {};

  for (final String path in paths) {
    envs.addAll(await _loadEnv(path, onError, env: envs, buildStep: buildStep));
  }

  return envs;
}

Future<Map<String, EnvVal>> _loadEnv(
  String path,
  void Function(String) onError, {
  required Map<String, EnvVal> env,
  BuildStep? buildStep,
}) async {
  final AssetId? assetId = _assetIdForPath(path, buildStep);

  if (assetId != null) {
    final List<String> lines = [];
    if (await buildStep!.canRead(assetId)) {
      lines.addAll(
        const LineSplitter().convert(await buildStep.readAsString(assetId)),
      );
    } else {
      onError("Environment variable file doesn't exist at `$path`.");
    }

    return Parser.parse(lines, env: env);
  }

  final File file = File.fromUri(Uri.file(path));

  final List<String> lines = [];
  if (await file.exists()) {
    lines.addAll(await file.readAsLines());
  } else {
    onError("Environment variable file doesn't exist at `$path`.");
  }

  return Parser.parse(lines, env: env);
}

AssetId? _assetIdForPath(String path, BuildStep? buildStep) {
  if (buildStep == null || File(path).isAbsolute) {
    return null;
  }

  try {
    return AssetId(buildStep.inputId.package, path);
  } on ArgumentError {
    return null;
  } on NoSuchMethodError {
    // source_gen_test passes a mock BuildStep that does not expose inputId.
    return null;
  }
}

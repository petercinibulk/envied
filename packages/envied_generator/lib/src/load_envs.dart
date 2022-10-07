import 'dart:io' show File;

import 'package:envied_generator/src/parser.dart';
// ignore: implementation_imports

/// Load the environment variables from the supplied [path],
/// using the `dotenv` parser.
///
/// If file doesn't exist, an error will be thrown through the
/// [onError] function.
Future<Map<String, String>> loadEnvs(
  String path,
  Function(String) onError,
) async {
  const parser = Parser();
  final file = File.fromUri(Uri.file(path));

  var lines = <String>[];
  if (await file.exists()) {
    lines = await file.readAsLines();
  } else {
    onError("Environment variable file doesn't exist at `$path`.");
  }

  final envs = parser.parse(lines);
  return envs;
}

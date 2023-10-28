import 'dart:io' show File;

import 'package:build/build.dart';
import 'package:envied_generator/src/parser.dart';

/// Load the environment variables from the supplied [path],
/// using the `dotenv` parser.
///
/// If file doesn't exist, an error will be thrown through the
/// [onError] function.
Future<Map<String, String>> loadEnvs(
  String path,
  Function(String) onError,
) async {
  final File file = File.fromUri(Uri.file(path));

  final List<String> lines = [];
  if (await file.exists()) {
    lines.addAll(await file.readAsLines());
  } else {
    String message = "Environment variable file doesn't exist at `$path`.";
    log.warning(message);
    onError(message);
  }

  return Parser.parse(lines);
}

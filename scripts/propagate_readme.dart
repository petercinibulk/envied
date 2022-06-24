import 'dart:io' show Directory, File;
import 'package:path/path.dart' show joinAll;

void main() {
  final readmeFile = File(joinAll(
    [Directory.current.path, 'README.md'],
  ));
  final outputPaths = [
    joinAll(
      [Directory.current.path, 'packages', 'envied', 'README.md'],
    ),
  ];
  // ignore: avoid_print
  for (String outputPath in outputPaths) {
    print('Updating README: $outputPath');
    readmeFile.copySync(outputPath);
  }

  // ignore: avoid_print
  print('READMEs Propagated ✅');
}

import 'dart:convert' show jsonEncode;
import 'dart:io';
import 'dart:isolate';

import 'package:test/test.dart';

void main() {
  group('build_runner loads hidden env files without build.yaml', () {
    for (final String envPath in <String>['.env', '.env/.env.dev']) {
      test(
        envPath,
        () => _expectBuildSucceeds(envPath),
        timeout: const Timeout(Duration(minutes: 2)),
      );
    }
  });
}

Future<void> _expectBuildSucceeds(String envPath) async {
  final Uri generatorLibUri = (await Isolate.resolvePackageUri(
    Uri.parse('package:envied_generator/'),
  ))!;
  final Directory generatorPackage = Directory.fromUri(
    generatorLibUri.resolve('../'),
  );
  final Directory enviedPackage = Directory.fromUri(
    generatorPackage.uri.resolve('../envied/'),
  );
  final Directory fixture = await Directory.systemTemp.createTemp(
    'envied_hidden_env_',
  );

  try {
    await _writeFixture(
      fixture,
      envPath: envPath,
      generatorPackage: generatorPackage,
      enviedPackage: enviedPackage,
    );

    // The workspace bootstrap has already populated the pub cache. Resolve the
    // temporary fixture offline so this test does not depend on network access.
    final ProcessResult pubGet = await Process.run(
      Platform.resolvedExecutable,
      <String>['pub', 'get', '--offline'],
      workingDirectory: fixture.path,
    );
    expect(
      pubGet.exitCode,
      0,
      reason: 'dart pub get failed:\n${pubGet.stdout}\n${pubGet.stderr}',
    );

    final ProcessResult build = await Process.run(
      Platform.resolvedExecutable,
      <String>['run', 'build_runner', 'build'],
      workingDirectory: fixture.path,
    );
    expect(
      build.exitCode,
      0,
      reason:
          'build_runner failed for `$envPath` without build.yaml:\n'
          '${build.stdout}\n${build.stderr}',
    );

    final String generated = await File.fromUri(
      fixture.uri.resolve('lib/app_env.g.dart'),
    ).readAsString();
    expect(generated, contains('hidden-env-secret'));
  } finally {
    await fixture.delete(recursive: true);
  }
}

Future<void> _writeFixture(
  Directory fixture, {
  required String envPath,
  required Directory generatorPackage,
  required Directory enviedPackage,
}) async {
  await Directory.fromUri(fixture.uri.resolve('lib/')).create(recursive: true);

  await File.fromUri(fixture.uri.resolve('pubspec.yaml')).writeAsString('''
name: envied_hidden_directory_fixture
publish_to: none

environment:
  sdk: ^3.9.0

dependencies:
  envied: ^1.3.6

dev_dependencies:
  build_runner: ^2.15.0
  envied_generator:
    path: ${jsonEncode(generatorPackage.path)}

dependency_overrides:
  envied:
    path: ${jsonEncode(enviedPackage.path)}
''');
  final File envFile = File.fromUri(fixture.uri.resolve(envPath));
  await envFile.parent.create(recursive: true);
  await envFile.writeAsString('SECRET_KEY=hidden-env-secret\n');
  await File.fromUri(fixture.uri.resolve('lib/app_env.dart')).writeAsString('''
import 'package:envied/envied.dart';

part 'app_env.g.dart';

@Envied(path: ${jsonEncode(envPath)}, requireEnvFile: true)
abstract class AppEnv {
  @EnviedField(varName: 'SECRET_KEY')
  static const String secretKey = _AppEnv.secretKey;
}
''');
}

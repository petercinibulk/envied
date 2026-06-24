import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:envied_generator/builder.dart';
import 'package:test/test.dart';

void main() {
  test('loads the default env file from the input package', () async {
    final AssetId input = AssetId('envied_generator', 'lib/default_env.dart');
    final AssetId env = AssetId('envied_generator', '.env');

    final TestBuilderResult result = await _build(input, <String, Object>{
      '$input': '''
import 'package:envied/envied.dart';

@Envied(requireEnvFile: true)
abstract class DefaultEnv {
  @EnviedField()
  static const String? apiUrl = null;
}
''',
      '$env': 'apiUrl=https://package.example',
    });

    expect(result.succeeded, isTrue);
    expect(result.readerWriter.testing.inputsTracked, contains(env));
    expect(
      result.readerWriter.testing.readString(
        input.changeExtension('.envied.g.part'),
      ),
      contains("static const String apiUrl = 'https://package.example';"),
    );
  });

  test('loads inherited env files from the input package', () async {
    final AssetId input = AssetId('envied_generator', 'lib/inherited_env.dart');
    final AssetId defaults = AssetId('envied_generator', 'config/defaults.env');
    final AssetId env = AssetId('envied_generator', 'config/local.env');

    final TestBuilderResult result = await _build(input, <String, Object>{
      '$input': '''
import 'package:envied/envied.dart';

@Envied(
  path: 'config/local.env',
  inheritFrom: ['config/defaults.env'],
  requireEnvFile: true,
)
abstract class InheritedEnv {
  @EnviedField()
  static const String? apiUrl = null;

  @EnviedField()
  static const String? feature = null;
}
''',
      '$defaults': '''
apiUrl=https://default.example
feature=off
''',
      '$env': 'apiUrl=https://local.example',
    });

    expect(result.succeeded, isTrue);
    expect(result.readerWriter.testing.inputsTracked, contains(defaults));
    expect(result.readerWriter.testing.inputsTracked, contains(env));
    expect(
      result.readerWriter.testing.readString(
        input.changeExtension('.envied.g.part'),
      ),
      allOf(
        contains("static const String apiUrl = 'https://local.example';"),
        contains("static const String feature = 'off';"),
      ),
    );
  });

  test('loads an env file from a hidden package directory', () async {
    final AssetId input = AssetId(
      'envied_generator',
      'lib/hidden_directory_env.dart',
    );
    final AssetId env = AssetId('envied_generator', 'test/.env/.env.dev');

    final TestBuilderResult result = await _build(
      input,
      <String, Object>{
        '$input': '''
import 'package:envied/envied.dart';

@Envied(path: 'test/.env/.env.dev', requireEnvFile: true)
abstract class HiddenDirectoryEnv {
  @EnviedField(varName: 'SECRET_KEY')
  static const String? secretKey = null;
}
''',
      },
      unreadableAssets: <AssetId>[env],
    );

    expect(result.succeeded, isTrue);
    expect(result.readerWriter.testing.inputsTracked, contains(env));
    expect(
      result.readerWriter.testing.readString(
        input.changeExtension('.envied.g.part'),
      ),
      contains("static const String secretKey = 'hidden-directory-secret';"),
    );
  });

  test('does not bypass the asset graph for non-hidden paths', () async {
    final AssetId input = AssetId(
      'envied_generator',
      'lib/unreadable_env.dart',
    );
    final AssetId env = AssetId('envied_generator', 'test/stale_generated.env');

    final TestBuilderResult result = await _build(
      input,
      <String, Object>{
        '$input': '''
import 'package:envied/envied.dart';

@Envied(path: 'test/stale_generated.env')
abstract class UnreadableEnv {
  @EnviedField(
    varName: 'STALE_GENERATED_SECRET',
    defaultValue: 'default-secret',
  )
  static const String? secretKey = null;
}
''',
      },
      unreadableAssets: <AssetId>[env],
    );

    expect(result.succeeded, isTrue);
    expect(result.readerWriter.testing.inputsTracked, contains(env));
    expect(
      result.readerWriter.testing.readString(
        input.changeExtension('.envied.g.part'),
      ),
      allOf(
        contains("static const String secretKey = 'default-secret';"),
        isNot(contains('stale-secret')),
      ),
    );
  });
}

Future<TestBuilderResult> _build(
  AssetId input,
  Map<String, Object> sourceAssets, {
  Iterable<AssetId> unreadableAssets = const <AssetId>[],
}) async {
  final TestReaderWriter readerWriter = TestReaderWriter(
    rootPackage: input.package,
  );
  await readerWriter.testing.loadIsolateSources();
  for (final AssetId asset in unreadableAssets) {
    readerWriter.testing.delete(asset);
  }

  return testBuilder(
    enviedBuilder(BuilderOptions.empty),
    sourceAssets,
    rootPackage: input.package,
    readerWriter: readerWriter,
    flattenOutput: true,
  );
}

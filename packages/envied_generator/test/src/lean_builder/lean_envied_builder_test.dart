import 'package:envied_generator/src/lean_builder/lean_envied_builder.dart';
import 'package:lean_builder/builder.dart';
import 'package:test/test.dart';

void main() {
  group('LeanEnviedBuilder', () {
    test('creates with null options', () {
      final builder = LeanEnviedBuilder(null);
      expect(builder.options, null);
    });

    test('creates with options', () {
      final options = BuilderOptions({'path': '.env.test'});
      final builder = LeanEnviedBuilder(options);
      expect(builder.options, isNotNull);
      expect(builder.options!.config['path'], '.env.test');
    });

    test('outputExtensions returns .g.dart', () {
      final builder = LeanEnviedBuilder(null);
      expect(builder.outputExtensions, {'.g.dart'});
    });

    group('shouldBuildFor', () {
      test('returns false for non-Dart files', () {
        final builder = LeanEnviedBuilder(null);
        final candidate = _MockBuildCandidate(
          isDartSource: false,
          hasTopLevelMetadata: true,
          hasClasses: true,
        );

        expect(builder.shouldBuildFor(candidate), false);
      });

      test('returns false for files without top-level metadata', () {
        final builder = LeanEnviedBuilder(null);
        final candidate = _MockBuildCandidate(
          isDartSource: true,
          hasTopLevelMetadata: false,
          hasClasses: true,
        );

        expect(builder.shouldBuildFor(candidate), false);
      });

      test('returns false for files without classes', () {
        final builder = LeanEnviedBuilder(null);
        final candidate = _MockBuildCandidate(
          isDartSource: true,
          hasTopLevelMetadata: true,
          hasClasses: false,
        );

        expect(builder.shouldBuildFor(candidate), false);
      });

      test('returns true for Dart files with metadata and classes', () {
        final builder = LeanEnviedBuilder(null);
        final candidate = _MockBuildCandidate(
          isDartSource: true,
          hasTopLevelMetadata: true,
          hasClasses: true,
        );

        expect(builder.shouldBuildFor(candidate), true);
      });
    });
  });
}

class _MockBuildCandidate implements BuildCandidate {
  _MockBuildCandidate({
    required this.isDartSource,
    required this.hasTopLevelMetadata,
    required this.hasClasses,
  });

  @override
  final bool isDartSource;

  @override
  final bool hasTopLevelMetadata;

  @override
  final bool hasClasses;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

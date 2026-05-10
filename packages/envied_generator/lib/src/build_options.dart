/// Represents the options passed to the build runner via build.yaml.
///
/// For example
///
/// ```yaml
/// targets:
///   $default:
///     builders:
///       envied_generator|envied:
///         options:
///           path: .env.test
///           pathOverrides:
///             ProductionEnv: .env.production
///             DebugEnv: .env.debug
///           override: true
/// ```
class BuildOptions {
  const BuildOptions({this.override, this.path, this.pathOverrides = const {}});

  final String? path;
  final Map<String, String> pathOverrides;
  final bool? override;

  factory BuildOptions.fromMap(Map<String, dynamic> map) => BuildOptions(
    override: map['override'] as bool?,
    path: map['path'] as String?,
    pathOverrides: _parsePathOverrides(map['pathOverrides']),
  );

  static Map<String, String> _parsePathOverrides(Object? pathOverrides) {
    if (pathOverrides == null) {
      return const {};
    }

    if (pathOverrides is! Map) {
      throw ArgumentError.value(
        pathOverrides,
        'pathOverrides',
        'Expected a map with string keys and string values.',
      );
    }

    final Map<String, String> parsed = <String, String>{};

    for (final MapEntry<dynamic, dynamic> entry in pathOverrides.entries) {
      final dynamic key = entry.key;
      final dynamic value = entry.value;

      if (key is! String || value is! String) {
        throw ArgumentError.value(
          pathOverrides,
          'pathOverrides',
          'Expected a map with string keys and string values.',
        );
      }

      parsed[key] = value;
    }

    return Map<String, String>.unmodifiable(parsed);
  }
}

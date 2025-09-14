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
///           override: true
/// ```
class BuildOptions {
  const BuildOptions({this.override, this.path});

  final String? path;
  final bool? override;

  factory BuildOptions.fromMap(Map<String, dynamic> map) => BuildOptions(
    override: map['override'] as bool?,
    path: map['path'] as String?,
  );
}

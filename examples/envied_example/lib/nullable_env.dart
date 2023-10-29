// lib/env/env.dart
import 'package:envied/envied.dart';

part 'nullable_env.g.dart';

@Envied(path: '.env', allowOptionalFields: false)
final class NullableEnv {
  @EnviedField(optional: true)
  static const String? key6 = _NullableEnv.key6;
}

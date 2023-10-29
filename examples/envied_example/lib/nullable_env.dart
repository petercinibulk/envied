// lib/env/env.dart
import 'package:envied/envied.dart';

part 'nullable_env.g.dart';

@Envied(path: '.env', allowOptionalFields: true)
final class NullableEnv {
  @EnviedField()
  static const String? key6 = _NullableEnv.key6;
}

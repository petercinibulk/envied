import 'package:equatable/equatable.dart';

class EnvVal with EquatableMixin {
  const EnvVal({
    required this.raw,
    String? interpolated,
  }) : interpolated = interpolated ?? raw;

  final String raw;
  final String interpolated;

  @override
  String toString() => interpolated;

  @override
  List<Object?> get props => [raw, interpolated];
}

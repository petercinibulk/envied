import 'package:equatable/equatable.dart';

/// Represents a raw environment variable as well as its interpolated value.
class EnvVal with EquatableMixin {
  const EnvVal({required this.raw, String? interpolated})
    : interpolated = interpolated ?? raw;

  final String raw;
  final String interpolated;

  @override
  String toString() => interpolated;

  @override
  List<Object?> get props => [raw, interpolated];
}

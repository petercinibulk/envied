import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  /// Return `true` if this type represents the type 'Uri' defined in the
  /// dart:core library.
  bool get isDartCoreUri =>
      element?.name == 'Uri' && element?.library?.isDartCore == true;

  /// Return `true` if this type represents the type 'DateTime' defined in the
  /// dart:core library.
  bool get isDartCoreDateTime =>
      element?.name == 'DateTime' && element?.library?.isDartCore == true;
}

import 'package:analyzer/dart/element/element.dart';
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

  /// Return `true` if the type extends the type 'Enum'.
  /// Unlike `isDartCoreEnum` it is not not restricted to the dart:core library.
  bool get isDartEnum => element is EnumElement;
}

extension EnumElementExtension on EnumElement {
  /// Return the fields defined in this enum.
  Iterable<FieldElement> get values =>
      fields.where((FieldElement fe) => fe.isEnumConstant);

  /// Return the names of the values defined by this enum.
  Iterable<String> get valueNames => values.map((FieldElement fe) => fe.name);
}

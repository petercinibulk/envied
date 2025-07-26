import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  /// Return `true` if this type represents the type 'Uri' defined in the
  /// dart:core library.
  bool get isDartCoreUri =>
      element3?.name3 == 'Uri' && element3?.library2?.isDartCore == true;

  /// Return `true` if this type represents the type 'DateTime' defined in the
  /// dart:core library.
  bool get isDartCoreDateTime =>
      element3?.name3 == 'DateTime' && element3?.library2?.isDartCore == true;

  /// Return `true` if the type extends the type 'Enum'.
  /// Unlike `isDartCoreEnum` it is not not restricted to the dart:core library.
  bool get isDartEnum => element3 is EnumElement2;
}

extension EnumElementExtension on EnumElement2 {
  /// Return the fields defined in this enum.
  Iterable<FieldElement2> get values =>
      fields2.where((FieldElement2 fe) => fe.isEnumConstant);

  /// Return the names of the values defined by this enum.
  Iterable<String> get valueNames =>
      values.map((FieldElement2 fe) => fe.name3!);
}

/// Taken from https://stackoverflow.com/questions/76038472/limit-string-split-to-a-maximum-number-of-elements#answer-76039017
extension PartialSplit on String {
  /// A version of [String.split] that limits splitting to return a [List]
  /// of at most [count] items.
  ///
  /// [count] must be non-negative.  If [count] is 0, returns an empty
  /// [List].
  ///
  /// If splitting this [String] would result in more than [count] items,
  /// the final element will contain the unsplit remainder of this [String].
  ///
  /// If splitting this [String] would result in fewer than [count] items,
  /// returns a [List] with only the split substrings.
  List<String> partialSplit(Pattern pattern, int count) {
    assert(count >= 0);

    final List<String> result = [];

    if (count == 0) {
      return result;
    }

    int offset = 0;
    final Iterable<Match> matches = pattern.allMatches(this);
    for (var match in matches) {
      if (result.length + 1 == count) {
        break;
      }

      if (match.end - match.start == 0 && match.start == offset) {
        continue;
      }

      result.add(substring(offset, match.start));
      offset = match.end;
    }
    result.add(substring(offset));

    return result;
  }
}

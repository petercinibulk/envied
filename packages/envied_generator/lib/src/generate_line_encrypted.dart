import 'dart:math';

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

/// Generate the line to be used in the generated class.
/// If [value] is `null`, it means the variable definition doesn't exist
/// and an [InvalidGenerationSourceError] will be thrown.
///
/// Since this function also does the type casting,
/// an [InvalidGenerationSourceError] will also be thrown if
/// the type can't be casted, or is not supported.
String generateLineEncrypted(FieldElement field, String? value) {
  if (value == null) {
    throw InvalidGenerationSourceError(
      'Environment variable not found for field `${field.name}`.',
      element: field,
    );
  }

  final Random rand = Random.secure();
  final String type = field.type.getDisplayString(withNullability: false);
  final String name = field.name;
  final String keyName = '_enviedkey$name';

  switch (type) {
    case "int":
      final int? parsed = int.tryParse(value);
      if (parsed == null) {
        throw InvalidGenerationSourceError(
          'Type `$type` does not align up to value `$value`.',
          element: field,
        );
      } else {
        final int key = rand.nextInt(1 << 32);
        final int encValue = parsed ^ key;
        return 'static final int $keyName = $key;\n'
            'static final int $name = $keyName ^ $encValue;';
      }
    case "bool":
      final String lowercaseValue = value.toLowerCase();
      if (['true', 'false'].contains(lowercaseValue)) {
        final bool parsed = lowercaseValue == 'true';
        final bool key = rand.nextBool();
        final bool encValue = parsed ^ key;
        return 'static final bool $keyName = $key;\n'
            'static final bool $name = $keyName ^ $encValue;';
      } else {
        throw InvalidGenerationSourceError(
          'Type `$type` does not align up to value `$value`.',
          element: field,
        );
      }
    case "String":
    case "dynamic":
      final List<int> parsed = value.codeUnits;
      final List<int> key = parsed.map((e) => rand.nextInt(1 << 32)).toList(
            growable: false,
          );
      final List<int> encValue =
          List.generate(parsed.length, (i) => i, growable: false)
              .map((i) => parsed[i] ^ key[i])
              .toList(growable: false);
      final String encName = '_envieddata$name';
      return 'static const List<int> $keyName = [${key.join(", ")}];\n'
          'static const List<int> $encName = [${encValue.join(", ")}];\n'
          'static final ${type == 'dynamic' ? '' : 'String'} $name = String.fromCharCodes(\n'
          '  List.generate($encName.length, (i) => i, growable: false)\n'
          '      .map((i) => $encName[i] ^ $keyName[i])\n'
          '      .toList(growable: false),\n'
          ');';
    default:
      throw InvalidGenerationSourceError(
        'Obfuscated envied can only handle types such as `int`, `bool` and `String`. Type `$type` is not one of them.',
        element: field,
      );
  }
}

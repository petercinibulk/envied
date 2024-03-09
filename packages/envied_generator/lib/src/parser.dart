/// Creates key-value pairs from strings formatted as environment
/// variable definitions.
final class Parser {
  static const String _singleQuot = "'";
  static const String _doubleQuot = '"';
  static final RegExp _leadingExport = RegExp(r'''^ *export ?''');
  static final RegExp _comment = RegExp(r'''#[^'"]*$''');
  static final RegExp _commentWithQuotes = RegExp(r'''#.*$''');
  static final RegExp _surroundQuotes = RegExp(r'''^(["'])(.*?[^\\])\1''');
  static final RegExp _bashVar =
      RegExp(r'''(\\)?(\$)(?:{)?([a-zA-Z_][\w]*)+(?:})?''');

  /// Creates a [Map](dart:core).
  /// Duplicate keys are silently discarded.
  static Map<String, String> parse(Iterable<String> lines) {
    final Map<String, String> out = {};
    for (final String line in lines) {
      final Map<String, String> kv = parseOne(line, env: out);
      if (kv.isNotEmpty) {
        out.putIfAbsent(kv.keys.single, () => kv.values.single);
      }
    }
    return out;
  }

  /// Parses a single line into a key-value pair.
  static Map<String, String> parseOne(
    String line, {
    Map<String, String> env = const {},
  }) {
    final String stripped = strip(line);

    /// If the line is empty or a comment, return an empty map.
    if (!_isValid(stripped)) return {};

    /// Split the line into key and value.
    final [String lhs, String rhs] = stripped.split('=');

    /// Remove the 'export' keyword.
    final String key = swallow(lhs);

    /// If the key is empty, return an empty map.
    if (key.isEmpty) return {};

    /// Get the quote character, if any.
    final String quotChar = surroundingQuote(rhs.trim());

    /// Remove quotes
    String val = unquote(rhs.trim());

    /// Values with single quotes are not interpolated.
    if (quotChar == _singleQuot) {
      return {
        key: val.replaceAll(r"\'", "'"),
      };
    }

    /// Values with double quotes are interpolated.
    if (quotChar == _doubleQuot) {
      val = val.replaceAll(r'\"', '"').replaceAll(r'\n', '\n');
    }

    return {
      key: interpolate(val, env).replaceAll(r'\$', r'$'),
    };
  }

  /// Substitutes $bash_vars in [val] with values from [env].
  static String interpolate(String val, Map<String, String?> env) =>
      val.replaceAllMapped(_bashVar, (Match match) {
        if ((match.group(1) ?? '') == r'\') {
          return match.input.substring(match.start, match.end);
        } else {
          final String key = match.group(3)!;
          return _has(env, key) ? env[key]! : '';
        }
      });

  /// If [val] is wrapped in single or double quotes, returns the quote character.
  /// Otherwise, returns the empty string.
  static String surroundingQuote(String val) => _surroundQuotes.hasMatch(val)
      ? _surroundQuotes.firstMatch(val)!.group(1)!
      : '';

  /// Removes quotes (single or double) surrounding a value.
  static String unquote(String val) => _surroundQuotes.hasMatch(val)
      ? _surroundQuotes.firstMatch(val)!.group(2)!
      : strip(val, includeQuotes: true).trim();

  /// Strips comments (trailing or whole-line).
  static String strip(String line, {bool includeQuotes = false}) =>
      line.replaceAll(includeQuotes ? _commentWithQuotes : _comment, '').trim();

  /// Omits 'export' keyword.
  static String swallow(String line) =>
      line.replaceAll(_leadingExport, '').trim();

  static bool _isValid(String s) => s.isNotEmpty && s.contains('=');

  /// [ null ] is a valid value in a Dart map, but the env var representation is empty string, not the string 'null'
  static bool _has(Map<String, String?> map, String key) =>
      map.containsKey(key) && map[key] != null;
}

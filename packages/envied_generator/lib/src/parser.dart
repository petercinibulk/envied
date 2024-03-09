/// Creates key-value pairs from strings formatted as environment
/// variable definitions.
final class Parser {
  static const String _singleQuot = "'";
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
    if (!_isValid(stripped)) return {};

    final int idx = stripped.indexOf('=');
    final String lhs = stripped.substring(0, idx);
    final String k = swallow(lhs);
    if (k.isEmpty) return {};

    final String rhs = stripped.substring(idx + 1, stripped.length).trim();
    final String quotChar = surroundingQuote(rhs);
    String v = unquote(rhs);
    if (quotChar == _singleQuot) {
      v = v.replaceAll(r"\'", "'");
      return {k: v};
    }
    if (quotChar == r'"') {
      v = v.replaceAll(r'\"', '"').replaceAll(r'\n', '\n');
    }
    final String interpolatedValue =
        interpolate(v, env).replaceAll(r'\$', r'$');
    return {k: interpolatedValue};
  }

  /// Substitutes $bash_vars in [val] with values from [env].
  static String interpolate(String val, Map<String, String?> env) =>
      val.replaceAllMapped(_bashVar, (Match m) {
        if ((m.group(1) ?? '') == r'\') {
          return m.input.substring(m.start, m.end);
        } else {
          final String k = m.group(3)!;
          return _has(env, k) ? env[k]! : '';
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
  static String strip(
    String line, {
    bool includeQuotes = false,
  }) =>
      line.replaceAll(includeQuotes ? _commentWithQuotes : _comment, '').trim();

  /// Omits 'export' keyword.
  static String swallow(String line) =>
      line.replaceAll(_leadingExport, '').trim();

  static bool _isValid(String s) => s.isNotEmpty && s.contains('=');

  /// [ null ] is a valid value in a Dart map, but the env var representation is empty string, not the string 'null'
  static bool _has(Map<String, String?> map, String key) =>
      map.containsKey(key) && map[key] != null;
}

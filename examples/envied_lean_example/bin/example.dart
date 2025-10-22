// ignore_for_file: avoid_print

import 'package:envied_lean_example/basic_example/env.dart';

/// Main example demonstrating lean builder
///
/// Run with: dart run bin/example.dart
void main() {
  print('=== Envied Lean Builder Example ===\n');

  print('📦 Basic Example (Lean Builder):');
  print('  KEY1: ${Env.key1}');
  print('  KEY2: ${Env.key2}');
  print('  KEY3: ${Env.key3}');
  print('  KEY4 (int): ${Env.key4}');
  print('  KEY5 (bool): ${Env.key5}');
  print('  KEY6 (Uri): ${Env.key6}');
  print('  KEY7 (DateTime): ${Env.key7}');
  print('  KEY9 (raw): ${Env.key9}');
  print('');

  print('✅ Lean builder example executed successfully!');
  print('\n💡 Generated with: dart run lean_builder build');
}

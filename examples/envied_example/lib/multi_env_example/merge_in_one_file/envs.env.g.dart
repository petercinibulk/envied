// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envs.env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env_debug
final class _Dev implements Envs {
  @override
  final String key1 = r'debug_foo';

  @override
  final String key2 = r'debug_bar';

  @override
  final String key3 = r'debug_baz';

  @override
  final int key4 = 456;

  @override
  final bool key5 = true;

  @override
  final Uri key6 = Uri.parse('http://zomg.test/bbq');

  @override
  final DateTime key7 = DateTime.parse('2022-09-01T12:01:12.001Z');

  @override
  final ExampleEnum key8 = ExampleEnum.values.byName('ipsum');

  @override
  final String key9 = r'unescaped$';
}

final class _Prod implements Envs {
  @override
  final String key1 = 'foo';

  @override
  final String key2 = 'bar';

  @override
  final String key3 = 'baz';

  @override
  final int key4 = 123;

  @override
  final bool key5 = false;

  @override
  final Uri key6 = Uri.parse('http://foo.bar/baz');

  @override
  final DateTime key7 = DateTime.parse('2023-11-06T23:09:51.123Z');

  @override
  final ExampleEnum key8 = ExampleEnum.values.byName('lorem');

  @override
  final String key9 = r'uneascaped$';
}

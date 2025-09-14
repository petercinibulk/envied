library;

import 'package:build/build.dart';
import 'package:envied_generator/envied_generator.dart';
import 'package:envied_generator/src/build_options.dart';
import 'package:source_gen/source_gen.dart';

/// Primary builder to build the generated code from the `EnviedGenerator`
Builder enviedBuilder(BuilderOptions options) => SharedPartBuilder([
  EnviedGenerator(BuildOptions.fromMap(options.config)),
], 'envied');

library envied.builder;

import 'package:build/build.dart';
import 'package:envied_generator/envied_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Primary builder to build the generated code from the `EnviedGenerator`
Builder enviedBuilder(BuilderOptions options) =>
    SharedPartBuilder([const EnviedGenerator()], 'envied');

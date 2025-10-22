import 'dart:async';

import 'package:code_builder/code_builder.dart';
import 'package:envied/envied.dart';
import 'package:envied_generator/src/build_options.dart';
import 'package:envied_generator/src/env_val.dart';
import 'package:envied_generator/src/load_envs.dart';
import 'package:lean_builder/builder.dart';
import 'package:lean_builder/element.dart';

import 'build_utils.dart';
import 'lean_envied_resolver.dart';
import 'lean_field_generator.dart';

/// Lean builder for generating environment variable classes from @Envied annotations.
///
/// This builder is the lean_builder alternative to the build_runner-based generator.
/// It generates `.g.dart` files containing environment variable access classes from
/// classes annotated with @Envied and fields annotated with @EnviedField.
///
/// The builder is automatically discovered by lean_builder via the @LeanBuilder
/// annotation. It supports all envied features including:
/// - Plain and obfuscated environment variables
/// - Multiple environment configurations
/// - Optional fields with defaults
/// - Type-safe access (String, int, bool, double, num, Uri, DateTime, Enum)
/// - Environment variable interpolation
/// - System environment variable delegation
///
/// Usage:
/// ```sh
/// dart run lean_builder build
/// ```
///
/// Configuration:
/// Configure via `build.yaml`:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       envied_generator|envied_lean:
///         enabled: true
///         options:
///           path: .env.custom  # Optional path override
///           override: true
/// ```
@LeanBuilder(registerTypes: {Envied, EnviedField})
class LeanEnviedBuilder extends Builder {
  /// Annotation name constant for @Envied.
  ///
  /// Using a constant prevents typos and allows potential compiler optimizations.
  static const String _enviedAnnotationName = 'Envied';

  /// Annotation name constant for @EnviedField.
  ///
  /// Using a constant prevents typos and allows potential compiler optimizations.
  static const String _enviedFieldAnnotationName = 'EnviedField';

  /// Shared resolver instance for annotation parsing.
  ///
  /// Reusing a single instance across all annotations reduces memory
  /// allocations and improves performance. The resolver is stateless.
  final LeanEnviedResolver _resolver = LeanEnviedResolver();

  /// Build options provided via build.yaml or command line.
  ///
  /// Contains configuration like path overrides and other builder settings.
  final BuilderOptions? options;

  /// Creates a new [LeanEnviedBuilder] with the specified [options].
  ///
  /// The [options] parameter is typically provided by the lean_builder framework
  /// and contains build.yaml configuration merged with command-line arguments.
  LeanEnviedBuilder(this.options);

  /// Parsed build options specific to envied.
  ///
  /// Converts the generic [BuilderOptions] into typed [BuildOptions] for
  /// easier access to envied-specific configuration like path overrides.
  BuildOptions? get _buildOptions =>
      options != null ? BuildOptions.fromMap(options!.config) : null;

  /// The file extensions that this builder will output.
  ///
  /// Returns `{'.g.dart'}` to indicate this builder generates part files
  /// with the `.g.dart` extension.
  @override
  Set<String> get outputExtensions => {'.g.dart'};

  /// Determines if the builder should process the given build candidate.
  ///
  /// Performs quick checks to filter out files that definitely don't need
  /// processing, improving build performance by skipping unnecessary work.
  ///
  /// Returns:
  /// `true` if the file is a Dart source file that contains both top-level
  /// metadata (annotations) and class declarations, `false` otherwise.
  ///
  /// This check is optimized to avoid parsing files that couldn't possibly
  /// contain @Envied annotations.
  @override
  bool shouldBuildFor(BuildCandidate candidate) {
    return candidate.isDartSource &&
        candidate.hasTopLevelMetadata &&
        candidate.hasClasses;
  }

  /// Executes the build process for the given [buildStep].
  ///
  /// This is the main entry point for code generation. It:
  /// 1. Finds all classes annotated with @Envied
  /// 2. For each class, processes all @Envied annotations (supporting multiple environments)
  /// 3. Resolves configuration from annotations and build.yaml
  /// 4. Loads environment variables from .env files
  /// 5. Generates implementation classes for each environment
  /// 6. Writes the generated code to a `.g.dart` file
  ///
  /// The generated file will be either a part file (if the source uses `part`)
  /// or a standalone file.
  ///
  /// Parameters:
  /// - [buildStep]: The build step containing the source file and resolution context
  ///
  /// Throws:
  /// [InvalidGenerationSourceError] if there are errors in the annotations,
  /// missing environment variables, or type mismatches.
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    final typeChecker = resolver.typeCheckerOf<Envied>();
    final library = resolver.resolveLibrary(buildStep.asset);
    final annotatedElements = library.annotatedWithExact(typeChecker);

    if (annotatedElements.isEmpty) return;

    final generatedClasses = StringBuffer();
    final processedClasses = <ClassElement>{};

    for (final annotatedElement in annotatedElements) {
      final element = annotatedElement.element;

      throwIf(
        element is! ClassElement,
        '${element.name} is not a class element',
        element: element,
      );

      final classElement = element as ClassElement;

      // Skip if we've already processed this class (to handle multiple annotations)
      if (processedClasses.contains(classElement)) continue;
      processedClasses.add(classElement);

      // Process ALL @Envied annotations on this class
      final enviedAnnotations = _getAllEnviedAnnotations(classElement);
      final multipleAnnotations = enviedAnnotations.length > 1;

      for (final annotation in enviedAnnotations) {
        final generatedClass = await _generateClassForEnviedAnnotation(
          classElement: classElement,
          annotation: annotation,
          multipleAnnotations: multipleAnnotations,
        );

        generatedClasses.writeln(generatedClass);
      }
    }

    if (generatedClasses.isEmpty) return;

    // Determine if using part files based on the source file structure
    final String sourceFileName = buildStep.asset.uri.pathSegments.last;
    final bool usesPartBuilder = buildStep.hasValidPartDirectiveFor('.g.dart');

    // Build the header
    final StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    headerBuffer.writeln();
    headerBuffer.writeln(
        '// **************************************************************************');
    headerBuffer.writeln('// EnviedGenerator');
    headerBuffer.writeln(
        '// **************************************************************************');
    headerBuffer.writeln();

    if (usesPartBuilder) {
      headerBuffer.writeln("part of '$sourceFileName';");
      headerBuffer.writeln();
    }

    final content = '$headerBuffer$generatedClasses';
    await buildStep.writeAsString(content, extension: '.g.dart');
  }

  /// Generates code for a single @Envied annotation.
  ///
  /// This method handles the generation of one environment configuration class
  /// (e.g., `_DebugEnv`, `_ProductionEnv`). It:
  /// 1. Resolves the @Envied annotation configuration
  /// 2. Loads environment variables from the specified .env file
  /// 3. Processes all @EnviedField-annotated fields
  /// 4. Generates a class with static or instance fields
  ///
  /// When [multipleAnnotations] is true, the generated class implements the
  /// source interface and uses instance fields with `@override`. Otherwise,
  /// it generates static fields.
  ///
  /// Parameters:
  /// - [classElement]: The source class being annotated
  /// - [annotation]: The specific @Envied annotation to process
  /// - [multipleAnnotations]: Whether this class has multiple @Envied annotations
  ///
  /// Returns:
  /// A string containing the generated Dart class code.
  ///
  /// Throws:
  /// [InvalidGenerationSourceError] if environment variables are missing or
  /// there are type/configuration errors.
  Future<String> _generateClassForEnviedAnnotation({
    required ClassElement classElement,
    required ConstObject annotation,
    required bool multipleAnnotations,
  }) async {
    // Get override path from build options
    final String? overridePath = _buildOptions?.override == true &&
            _buildOptions?.path?.isNotEmpty == true
        ? _buildOptions?.path
        : null;

    // Resolve Envied configuration using shared resolver
    final Envied config =
        _resolver.resolveEnviedConfig(annotation, overridePath);

    // Load environment variables from .env file
    final Map<String, EnvVal> envs =
        await loadEnvs(config.path, (String error) {
      if (config.requireEnvFile) {
        throw InvalidGenerationSourceError(error, element: classElement);
      }
    });

    // Collect all fields with @EnviedField annotation
    final allFields = <Field>[];
    final fieldGenerator = LeanFieldGenerator(
      config: config,
      envs: envs,
      multipleAnnotations: multipleAnnotations,
    );

    for (final field in classElement.fields) {
      // Check if field has @EnviedField annotation
      final fieldAnnotation = _getEnviedFieldAnnotation(field);
      if (fieldAnnotation == null) continue;

      final fieldConfig = _resolver.resolveEnviedField(fieldAnnotation);
      final generatedFields =
          fieldGenerator.generateForField(field, fieldConfig);
      allFields.addAll(generatedFields);
    }

    // Generate the class using code_builder
    final DartEmitter emitter = DartEmitter(useNullSafetySyntax: true);

    final Class cls = Class(
      (classBuilder) => classBuilder
        ..modifier = ClassModifier.final$
        ..name = '_${config.name ?? classElement.name}'
        ..implements.addAll([
          if (multipleAnnotations) refer(classElement.name),
        ])
        ..fields.addAll(allFields),
    );

    return cls.accept(emitter).toString();
  }

  /// Gets all @Envied annotations from a class.
  ///
  /// Supports multiple @Envied annotations on a single class, enabling
  /// multi-environment configurations (e.g., @Envied for debug and production).
  ///
  /// Parameters:
  /// - [classElement]: The class to extract annotations from
  ///
  /// Returns:
  /// A list of [ConstObject] representing each @Envied annotation found.
  /// Returns an empty list if no @Envied annotations are present.
  List<ConstObject> _getAllEnviedAnnotations(ClassElement classElement) {
    final annotations = <ConstObject>[];
    for (final metadata in classElement.metadata) {
      if (metadata.name == _enviedAnnotationName) {
        final constant = metadata.constant;
        if (constant is ConstObject) {
          annotations.add(constant);
        }
      }
    }
    return annotations;
  }

  /// Gets the @EnviedField annotation from a field if it exists.
  ///
  /// Only fields annotated with @EnviedField will be included in the
  /// generated environment variable class.
  ///
  /// Parameters:
  /// - [field]: The field to check for @EnviedField annotation
  ///
  /// Returns:
  /// The [ConstObject] representation of the @EnviedField annotation,
  /// or `null` if the field is not annotated with @EnviedField.
  ConstObject? _getEnviedFieldAnnotation(FieldElement field) {
    for (final metadata in field.metadata) {
      if (metadata.name == _enviedFieldAnnotationName) {
        // Return the constant as ConstObject
        final constant = metadata.constant;
        if (constant is ConstObject) {
          return constant;
        }
      }
    }
    return null;
  }
}

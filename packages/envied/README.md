<div align="center">
    <h1>ENVied</h1>
</div>

<div align="center">
<a href="https://pub.dev/packages/envied"><img src="https://img.shields.io/pub/v/envied.svg" alt="Pub"></a>
<a href="https://github.com/petercinibulk/envied/actions/workflows/test.yaml"><img src="https://github.com/petercinibulk/envied/actions/workflows/test.yml/badge.svg" alt="CI"></a>
<a href=https://codecov.io/gh/petercinibulk/envied><img src="https://codecov.io/gh/petercinibulk/envied/branch/main/graph/badge.svg?token=uIX88zsd9c" alt="codecov"></a>
<a href="https://github.com/invertase/melos#readme-badge"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg?style=flat-square" alt="Melos" /></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</div>

<div align="center">

A cleaner way to handle your environment variables in Dart/Flutter.

(GREATLY inspired by [Envify](https://pub.dev/packages/envify))

</div>

<br>

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Overview](#overview)
- [Install](#install)
- [Usage](#usage)
  - [Obfuscation/Encryption](#obfuscationencryption)
  - [**Optional Environment Variables**](#optional-environment-variables)
  - [**Environment Variable Naming Conventions**](#environment-variable-naming-conventions)
- [License](#license)

<br>

## Overview

Using a `.env` file such as:

```.env
KEY=VALUE
```

or system environment variables such as:

```sh
export VAR=test
```

and a dart class:

```dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
    @EnviedField(varName: 'KEY')
    static const key = _Env.key;
}
```

Envied will generate the part file which contains the values from your `.env` file using build_runner

You can then use the Env class to access your environment variable:

```dart
print(Env.key); // "VALUE"
```

<br>

## Install

Add both `envied` and `envied_generator` as dependencies,

If you are using creating a Flutter project:

```sh
$ flutter pub add envied
$ flutter pub add --dev envied_generator
$ flutter pub add --dev build_runner
```

If you are using creating a Dart project:

```sh
$ dart pub add envied
$ dart pub add --dev envied_generator
$ dart pub add --dev build_runner
```

This installs three packages:

- [build_runner](https://pub.dev/packages/build_runner), the tool to run code-generators
- envied_generator, the code generator
- envied, a package containing the annotations.

<br>

## Usage

Add a `.env` file at the root of the project. The name of this file can be specified in your Envied class if you call it something else such as `.env.dev`.

```.env
KEY1=VALUE1
KEY2=VALUE2
```

Create a class to ingest the environment variables (`lib/env/env.dart`). Add the annotations for Envied on the class and EnviedField for any environment variables you want to be pulled from your `.env` file.

> IMPORTANT! Add both `.env` and `env.g.dart` files to your `.gitignore` file, otherwise, you might expose your environment variables.

```dart
// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
    @EnviedField(varName: 'KEY1')
    static const key1 = _Env.key1;
    @EnviedField()
    static const KEY2 = _Env.KEY2;
    @EnviedField(defaultValue: 'test_')
    static const key3 = _Env.key3;
}
```

Then run the generator:

```sh
dart run build_runner build
```

You can then use the Env class to access your environment variables:

```dart
print(Env.key1); // "VALUE1"
print(Env.KEY2); // "VALUE2"
```

### Obfuscation/Encryption

Add the `obfuscate` flag to EnviedField

```dart
@EnviedField(obfuscate: true)
```

**Please keep in mind that this only increases the amount of effort to retrieve the
obfuscated/encrypted values. If someone tries hard enough, he will eventually find the values.
For more information, see https://github.com/frencojobs/envify/pull/28 and
https://github.com/petercinibulk/envied/pull/4!**

### **Optional Environment Variables**

Enable `allowOptionalFields` to allow nullable types. When a default
value is not provided and the type is nullable, the generator will
assign the value to null instead of throwing an exception.

By default, optional fields are not enabled because it could be
confusing while debugging. If a field is nullable and a default
value is not provided, it will not throw an exception if it is
missing an environment variable.

For example, this could be useful if you are using an analytics service
for an open-source app, but you don't want to require users or contributors
to provide an API key if they build the app themselves.

```dart
@Envied(allowOptionalFields: true)
abstract class Env {
    @EnviedField()
    static const String? optionalServiceApiKey = _Env.optionalServiceApiKey;
}
```

Optional fields can also be enabled on a per-field basis by setting

```dart
@EnviedField(optional: true)
```

### **Environment Variable Naming Conventions**

The `envied` package provides a convenient way to handle environment variables in Dart applications. With the addition of the `useConstantCase` flag in the `@EnvField` and `@Envied` annotation, developers can now easily adhere to the [Dart convention](https://dart.dev/effective-dart/style#do-name-other-identifiers-using-lowercamelcase) for constant names. The `useConstantCase` flag allows the automatic transformation of field names from `camelCase` to `CONSTANT_CASE` when the `@EnvField` annotation is not explicitly assigned a `varName`.

By default, this is set to `false`, which means that the field name will retain its original format unless `varName` is specified. When set to `true`, the field name will be automatically transformed into `CONSTANT_CASE`, which is a commonly used case type for environment variable names.

```dart

@Envied(path: '.env', useConstantCase: true)
final class Env {

    @EnviedField()
    static const String apiKey = _Env.apiKey; // Transformed to 'API_KEY'


    @EnviedField(varName: 'apiKey')
    static const String apiKey = _Env.apiKey; // Searches for a variable named 'apiKey' inside the .env file and assigns it to apiKey

}
```

This option can also be enabled on a per-field basis by setting

```dart
@EnviedField(useConstantCase: true)
static const String apiKey; // Transformed to 'API_KEY'

@EnviedField()
static const String apiKey; // Retains its original value, which is `apiKey`

@EnviedField(varName: 'DEBUG_API_KEY')
static const String apiKey; // Searches for a variable named 'DEBUG_API_KEY' inside the .env file and assigns it to apiKey

```

These example illustrates how the field name `apiKey` is automatically transformed to `API_KEY`, adhering to the `CONSTANT_CASE` convention commonly used as the variable name inside the `.env` file. This feature contributes to improved code consistency and readability, while also aligning with [Effective Dart](https://dart.dev/effective-dart) naming conventions.

### **Build configuration overrides**

You can override the default `.env` file path by creating a `build.yaml` file in the root of your project.

```yaml
targets:
  $default:
    builders:
      envied_generator|envied:
        options:
          path: .env.custom
          override: true 
```

Note that **both** `path` and `override` must be set for the override to work.

### Known issues

When modifying the `.env` file, the generator might not pick up the change due to [dart-lang/build#967](https://github.com/dart-lang/build/issues/967).
If that happens simply clean the build cache and run the generator again.

```sh
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

For more information please see [petercinibulk/envied#6](https://github.com/petercinibulk/envied/issues/6#issuecomment-1243434607) 
and/or the original issue [dart-lang/build#967](https://github.com/dart-lang/build/issues/967).

<br>

## License

MIT © Peter Cinibulk

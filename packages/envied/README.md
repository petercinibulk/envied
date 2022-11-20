<div align="center">
    <h1>ENVied</h1>
</div>

<div align="center">
<a href="https://pub.dev/packages/envied"><img src="https://img.shields.io/pub/v/envied.svg" alt="Pub"></a>
<a href="https://github.com/petercinibulk/envied/actions/workflows/main.yaml"><img src="https://github.com/petercinibulk/envied/actions/workflows/main.yml/badge.svg" alt="CI"></a>
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
  - [Obfuscation](#obfuscation)
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

part 'env.g.dart'

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

-   [build_runner](https://pub.dev/packages/build_runner), the tool to run code-generators
-   envied_generator, the code generator
-   envied, a package containing the annotations.

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
# dart
dart run build_runner build
# flutter
flutter pub run build_runner build
```

You can then use the Env class to access your environment variables:

```dart
print(Env.key1); // "VALUE1"
print(Env.KEY2); // "VALUE2"
```

### Obfuscation
Add the ofuscate flag to EnviedField
```dart
@EnviedField(obfuscate: true)
```

<br>

## License

MIT © Peter Cinibulk

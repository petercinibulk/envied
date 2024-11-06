## 1.0.0

 - **FEAT**: add support for custom seed when using Random during the obfuscation.

## 0.5.4+1

 - **FIX**: fix parsing lines with multiple equal signs (#100)

## 0.5.4

 - **FEAT**: add support for raw strings and no interpolation (#95)
 - **FEAT**: add @envied annotation with default options (#92)

## 0.5.3

 - **FEAT**: optional path build.yaml option (#83)
 - **CHORE**: update readme regarding #6 (#79)

## 0.5.2

 - **FEAT**: add ability to convert field name from camelCase to CONSTANT_CASE (#42)

## 0.5.1

 - **FEAT**: add null value support (#61)

## 0.5.0

 - **REFACTOR**: facelift both Envied and EnviedGenerator to Dart 3.0 (#46).

## 0.3.0+3

 - **FIX**: revert dependencies to v0.3.0 (#34).

## 0.3.0+2

 - **FIX**: downgrade analyzer to 5.11.1 and lints 2.0.0.

## 0.3.0+1

 - **FIX**: CI workflow and dependency updates (#31).

## 0.3.0

> Note: This release has breaking changes.

 - **FEAT**: readme updated for defaultValue.
 - **FEAT**: the new unit tests for defaultValue added.
 - **FEAT**: defaultValue was added as parameter to EnviedField.
 - **FEAT**: default decorator was removed.
 - **FEAT**: Better documentation for obfuscation.
 - **FEAT**: add per-field obfuscation.
 - **FEAT**: add obfuscation option.
 - **FEAT**: add name parameter to Envied annotation.
 - **FEAT**: Pulls variable from Platform.environment if it doesn't exist in the .env.
 - **DOCS**: replace envName with varName in README.
 - **DOCS**: remove docs directory in the packages.
 - **DOCS**: updated readme with obfuscation option.
 - **DOCS**: add documentation for Envied name parameter.
 - **DOCS**: update readme.
 - **DOCS**: update readmes, pub listing and add readme propagation script.
 - **DOCS**: added docs and docs melos command.
 - **DOCS**: fixed errors in readme.md.
 - **BREAKING** **FIX**: Changed EnviedField parameter envName to varName to closer align meaning.
 - **BREAKING** **FIX**: Envied now runs build.

## 0.2.4

 - **FEAT**: Better documentation for obfuscation.
 - **DOCS**: replace envName with varName in README.
 - **DOCS**: remove docs directory in the packages.

## 0.2.3

 - **FEAT**: add per-field obfuscation.
 - **FEAT**: add obfuscation option.
 - **DOCS**: updated readme with obfuscation option.

## 0.2.2

 - **FEAT**: add name parameter to Envied annotation.
 - **DOCS**: add documentation for Envied name parameter.

## 0.2.1

 - **FEAT**: Pulls variable from Platform.environment if it doesn't exist in the .env.
 - **DOCS**: update readme.

## 0.2.0

> Note: This release has breaking changes.

 - **DOCS**: update readmes, pub listing and add readme propagation script.
 - **BREAKING** **FIX**: Changed EnviedField parameter envName to varName to closer align meaning.

## 0.1.0+1

 - **DOCS**: added docs and docs melos command.

## 0.1.0

> Note: This release has breaking changes.

 - **DOCS**: fixed errors in readme.md.
 - **BREAKING** **FIX**: Envied now runs build.

## 0.0.1

- Initial version.

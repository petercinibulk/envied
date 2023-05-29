## 0.3.1

 - **UPDATE**: dart analyzer from ^5.1.0 to ^5.13.0, now does not infer the data type

## 0.3.0+3

 - **FIX**: revert dependencies to v0.3.0 (#34).

## 0.3.0+2

 - **FIX**: downgrade analyzer to 5.11.1 and lints 2.0.0.

## 0.3.0+1

 - **FIX**(envied_generator): build extensions setting (#30).
 - **FIX**: CI workflow and dependency updates (#31).

## 0.3.0

> Note: This release has breaking changes.

 - **FEAT**: generator tests were added for defaultValue.
 - **FEAT**: defaultValue assignment added on generator side.
 - **FEAT**: default decorator was removed.
 - **FEAT**: add per-field obfuscation.
 - **FEAT**: add obfuscation option.
 - **FEAT**: add name parameter to Envied annotation.
 - **FEAT**: Pulls variable from Platform.environment if it doesn't exist in the .env.
 - **DOCS**: remove docs directory in the packages.
 - **DOCS**: update readmes, pub listing and add readme propagation script.
 - **DOCS**: added docs and docs melos command.
 - **DOCS**: fixed errors in readme.md.
 - **BREAKING** **FIX**: Changed EnviedField parameter envName to varName to closer align meaning.
 - **BREAKING** **FIX**: Envied now runs build.

## 0.2.3+1

 - **DOCS**: remove docs directory in the packages.

## 0.2.3

 - **FEAT**: add per-field obfuscation.
 - **FEAT**: add obfuscation option.

## 0.2.2

 - **FEAT**: add name parameter to Envied annotation.

## 0.2.1

 - **FEAT**: Pulls variable from Platform.environment if it doesn't exist in the .env.

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

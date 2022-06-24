import 'package:envied/envied.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow('`@Envied` can only be used on classes.')
@Envied()
const foo = 'bar';

@ShouldThrow("Environment variables file doesn't exist at `.env`.")
@Envied()
abstract class Env1 {}

@ShouldThrow('Environment variable not found for field `foo`.')
@Envied(path: 'test/.env.example')
abstract class Env2 {
  @EnviedField()
  static const dynamic foo = null;
}

@ShouldThrow(
  'Envied can only handle types such as `int`, `double`, `num`, `bool` and `String`. Type `Symbol` is not one of them.',
)
@Envied(path: 'test/.env.example')
abstract class Env3 {
  @EnviedField()
  static const Symbol? testString = null;
}

@ShouldThrow('Type `int` do not align up to value `testString`.')
@Envied(path: 'test/.env.example')
abstract class Env4 {
  @EnviedField()
  static const int? testString = null;
}

@ShouldThrow('Type `double` do not align up to value `testString`.')
@Envied(path: 'test/.env.example')
abstract class Env5 {
  @EnviedField()
  static const double? testString = null;
}

@ShouldThrow('Type `num` do not align up to value `testString`.')
@Envied(path: 'test/.env.example')
abstract class Env6 {
  @EnviedField()
  static const num? testString = null;
}

@ShouldThrow('Type `bool` do not align up to value `testString`.')
@Envied(path: 'test/.env.example')
abstract class Env7 {
  @EnviedField()
  static const bool? testString = null;
}

@ShouldGenerate('''
class _Env8 {
  static const String testString = 'testString';
  static const int testInt = 123;
  static const double testDouble = 1.23;
  static const bool testBool = true;
  static const testDynamic = '123abc';
}
''')
@Envied(path: 'test/.env.example')
abstract class Env8 {
  @EnviedField()
  static const String? testString = null;
  @EnviedField()
  static const int? testInt = null;
  @EnviedField()
  static const double? testDouble = null;
  @EnviedField()
  static const bool? testBool = null;
  @EnviedField()
  static const testDynamic = null;
}

@ShouldGenerate('''
class _Env9 {
  static const String testString = 'test_string';
}
''')
@Envied(path: 'test/.env.example')
abstract class Env9 {
  @EnviedField(varName: 'test_string')
  static const String? testString = null;
}

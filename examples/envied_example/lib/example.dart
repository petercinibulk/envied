import 'package:example/basic_example/env.dart';
import 'package:example/multi_env_example/merge_in_one_file/envs.env.dart';

void run() {
  print(Env.key1);
  print(Env.key2);
  print(Env.key3);
  print(Env.key4);
  print(Env.key5);
  print(Envs().key1);
}

import 'dart:io';

import 'package:git_hooks/git_hooks.dart';

void main(List<String> arguments) {
  Map<Git, UserBackFun> params = {
    Git.commitMsg: commitMsg,
    Git.preCommit: preCommit,
  };
  GitHooks.call(arguments, params);
}

Future<bool> commitMsg() async {
  var commitMsg = Utils.getCommitEditMsg();

  var validFormats = [
    'feat:',
    'fix:',
    'perf:',
    'style:',
    'docs:',
    'test:',
    'refactor:',
    'build:',
    'ci:',
    'chore:',
    'revert:',
    'wip:',
    'workflow:',
    'types:',
    'release:',
  ];

  if (validFormats.any((format) => commitMsg.startsWith(format))) {
    return true;
  } else {
    printErrorMessage();
    return false;
  }
}

Future<bool> preCommit() async {
  print('Dart 静态分析中。。。');
  var result = await Process.run('dart', ['analyze', 'lib']);
  print(result.stdout);
  print(result.stderr);
  return result.exitCode == 0;
}

void printErrorMessage() {
  const errorMessage = '错误：提交信息不符合规范，请按照规范提交。';
  const exampleMessage = '规范示例：feat: 添加新功能';
  const readmeMessage = '详细规范查看根目录README.md文件';

  print(errorMessage);
  print(exampleMessage);
  print(readmeMessage);
}

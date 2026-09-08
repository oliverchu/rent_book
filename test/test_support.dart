import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_book/data/services/password_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// widget 测试运行在 fake async 环境里，无法推进真实 isolate 的完成事件。
/// 注入同步执行器，保证密码哈希在测试中确定性完成。
Future<R> syncCompute<R>(R Function() computation) async => computation();

/// 测试用 [PasswordService]：哈希在当前线程同步执行。
///
/// 真实 isolate 路径由 `auth_test.dart` 中的纯 `test()` 用例覆盖。
PasswordService testPasswordService(SharedPreferences prefs) =>
    PasswordService(prefs, compute: syncCompute);

/// 把 widget 测试的设备语言固定为简体中文。
///
/// 应用跟随系统语言，测试断言因此可以直接比对 ARB 中的中文文案。
/// `Localizations` 使用 `platformDispatcher.locales` 解析语言，故两者都要设置。
void useChineseLocale(WidgetTester tester) {
  tester.platformDispatcher.localesTestValue = const <Locale>[Locale('zh')];
  tester.platformDispatcher.localeTestValue = const Locale('zh');
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
}

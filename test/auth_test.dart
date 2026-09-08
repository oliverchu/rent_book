import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/data/datasources/bill_store.dart';
import 'package:rent_book/data/repositories/bill_repository.dart';
import 'package:rent_book/data/services/password_service.dart';
import 'package:rent_book/l10n/app_localizations.dart';
import 'package:rent_book/main.dart';
import 'package:rent_book/ui/features/auth/change_password_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_support.dart';

Future<PasswordService> serviceWithoutPassword() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return testPasswordService(await SharedPreferences.getInstance());
}

Future<PasswordService> serviceWith(String password) async {
  final PasswordService service = await serviceWithoutPassword();
  await service.setPassword(password);
  return service;
}

void main() {
  test('PasswordService：设置后可验证，错误密码不通过', () async {
    final PasswordService service = await serviceWith('abcd');
    expect(service.hasPassword, isTrue);
    expect(await service.verify('abcd'), isTrue);
    expect(await service.verify('abce'), isFalse);
    expect(await service.verify(''), isFalse);
  });

  test('PasswordService：默认执行器在独立 isolate 中完成哈希（真实路径）', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final PasswordService service =
        PasswordService(await SharedPreferences.getInstance());
    await service.setPassword('abcd');
    expect(await service.verify('abcd'), isTrue);
    expect(await service.verify('abce'), isFalse);
  });

  testWidgets('首次使用：两次输入一致才能完成并进入首页', (WidgetTester tester) async {
    useChineseLocale(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final BillRepository repo = BillRepository(store: MemoryBillStore());
    await repo.load();
    final PasswordService service = testPasswordService(prefs);

    await tester.pumpWidget(RentBookApp(
      repository: repo,
      passwordService: service,
    ));
    await tester.pumpAndSettle();

    expect(find.text('设置启动密码'), findsOneWidget);

    // 两次不一致 → SnackBar 提示，停留在设置页
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), '1234');
    await tester.enterText(fields.at(1), '9999');
    await tester.tap(find.text('完成设置'));
    await tester.pumpAndSettle();
    expect(find.text('两次输入的密码不一致'), findsOneWidget);
    expect(service.hasPassword, isFalse, reason: '不一致时不应写入');

    // 修正为一致 → 成功
    await tester.enterText(fields.at(1), '1234');
    await tester.tap(find.text('完成设置'));
    await tester.pumpAndSettle();
    expect(await service.verify('1234'), isTrue);
    expect(find.text('还没有租户，先去添加一位吧'), findsOneWidget,
        reason: '设置完成后应直接进入首页');
  });

  testWidgets('修改密码：原密码校验 + 新密码两次一致 + 与原密码不同', (WidgetTester tester) async {
    final PasswordService service = await serviceWith('1234');
    // 模拟真实场景：从宿主页面 push 进入，修改成功后返回并弹出提示。
    await tester.pumpWidget(Provider<PasswordService>.value(
      value: service,
      child: MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('zh')],
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        const ChangePasswordView(),
                  ),
                ),
                child: const Text('打开修改页'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('打开修改页'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(3));

    // 原密码错误
    await tester.enterText(fields.at(0), '0000');
    await tester.enterText(fields.at(1), '5678');
    await tester.enterText(fields.at(2), '5678');
    await tester.tap(find.text('确认修改'));
    await tester.pumpAndSettle();
    expect(find.text('原密码不正确'), findsOneWidget);
    expect(await service.verify('5678'), isFalse);

    // 新旧相同
    await tester.enterText(fields.at(0), '1234');
    await tester.enterText(fields.at(1), '1234');
    await tester.enterText(fields.at(2), '1234');
    await tester.tap(find.text('确认修改'));
    await tester.pumpAndSettle();
    expect(find.text('新密码不能与原密码相同'), findsOneWidget);

    // 正确修改
    await tester.enterText(fields.at(0), '1234');
    await tester.enterText(fields.at(1), '5678');
    await tester.enterText(fields.at(2), '5678');
    await tester.tap(find.text('确认修改'));
    await tester.pumpAndSettle();
    expect(find.text('启动密码已修改 ✓'), findsOneWidget);
    expect(await service.verify('1234'), isFalse);
    expect(await service.verify('5678'), isTrue);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_book/data/datasources/bill_store.dart';
import 'package:rent_book/data/repositories/bill_repository.dart';
import 'package:rent_book/data/services/password_service.dart';
import 'package:rent_book/domain/models/bill.dart';
import 'package:rent_book/domain/models/tenant.dart';
import 'package:rent_book/l10n/app_localizations.dart';
import 'package:rent_book/main.dart';
import 'package:rent_book/ui/core/bill_card.dart';
import 'package:rent_book/ui/core/format.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_support.dart';

/// 种子数据：一位租户 + 当前月份账单；并预设已知启动密码 1234。
Future<(BillRepository, PasswordService)> seeded() async {
  final DateTime now = DateTime.now();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final BillRepository repo = BillRepository(store: MemoryBillStore());
  await repo.load();
  await repo.saveTenant(const Tenant(
    id: 't1',
    name: '张三',
    room: '101',
    rent: 150000,
    propertyFee: 20000,
  ));
  await repo.saveBill(Bill(
    id: 'b1',
    tenantId: 't1',
    year: now.year,
    month: now.month,
    rent: 150000,
    propertyFee: 20000,
    waterFee: 3560,
    electricityFee: 12045,
    gasFee: 4800,
    paid: false,
    note: '',
  ));

  final PasswordService service = testPasswordService(prefs);
  await service.setPassword('1234');
  return (repo, service);
}

void main() {
  testWidgets('启动需解锁，输入正确密码后进入首页', (WidgetTester tester) async {
    useChineseLocale(tester);
    final (BillRepository repo, PasswordService service) = await seeded();
    await tester.pumpWidget(RentBookApp(repository: repo, passwordService: service));
    await tester.pumpAndSettle();

    // 门禁页
    expect(find.text('收租啦已上锁'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '1234');
    await tester.tap(find.text('解锁'));
    await tester.pumpAndSettle();

    expect(find.text('101 · 张三'), findsOneWidget);
    expect(find.textContaining('本月应收合计'), findsOneWidget);
    // 汇总卡与租户卡各显示一次合计。
    expect(find.text('¥ 1,904.05'), findsNWidgets(2));
    expect(find.text('未收'), findsOneWidget);
  });

  testWidgets('密码错误时提示且不进入', (WidgetTester tester) async {
    useChineseLocale(tester);
    final (BillRepository repo, PasswordService service) = await seeded();
    await tester.pumpWidget(RentBookApp(repository: repo, passwordService: service));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '0000');
    await tester.tap(find.text('解锁'));
    await tester.pumpAndSettle();

    expect(find.text('密码错误，请重试'), findsOneWidget);
    expect(find.text('收租啦已上锁'), findsOneWidget);
  });

  testWidgets('账单卡片渲染明细与合计', (WidgetTester tester) async {
    final (BillRepository repo, _) = await seeded();
    final Bill bill = repo.bills.first;
    final Tenant tenant = repo.tenants.first;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('zh')],
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: BillCard(
              bill: bill,
              tenant: tenant,
              issuedOn: DateTime(2026, 9, 1),
            ),
          ),
        ),
      ),
    ));

    expect(find.text('房租缴费单'), findsOneWidget);
    expect(find.text(monthLabel(bill.year, bill.month, 'zh')), findsOneWidget);
    expect(find.text('101  张三'), findsOneWidget);
    for (final String label in <String>['房租', '物业费', '水费', '电费', '燃气费']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('¥ 1,904.05'), findsOneWidget); // 合计
    expect(find.text('应缴合计'), findsOneWidget);
    expect(find.text('出具日期：2026-09-01'), findsOneWidget);
  });
}

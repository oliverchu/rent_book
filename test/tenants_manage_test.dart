import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/data/datasources/bill_store.dart';
import 'package:rent_book/data/repositories/bill_repository.dart';
import 'package:rent_book/domain/models/bill.dart';
import 'package:rent_book/domain/models/tenant.dart';
import 'package:rent_book/l10n/app_localizations.dart';
import 'package:rent_book/ui/features/tenants/tenants_manage_view.dart';

Future<BillRepository> freshRepo({List<Tenant>? tenants}) async {
  final BillRepository repo = BillRepository(store: MemoryBillStore());
  await repo.load();
  for (final Tenant t in tenants ?? const <Tenant>[]) {
    await repo.saveTenant(t);
  }
  return repo;
}

const Tenant demo = Tenant(
  id: 't1',
  name: '张三',
  room: '101',
  rent: 150000,
  propertyFee: 20000,
);

Future<void> pumpManage(WidgetTester tester, BillRepository repo) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<BillRepository>.value(
      value: repo,
      child: MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('zh')],
        home: const TenantsManageView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('新增租户：填写完整信息后保存成功', (WidgetTester tester) async {
    final BillRepository repo = await freshRepo(tenants: const <Tenant>[demo]);
    await pumpManage(tester, repo);

    await tester.tap(find.text('新增租户'));
    await tester.pumpAndSettle();

    // 对话框标题与 FAB 标签同名，出现两处即证明对话框已打开。
    expect(find.text('新增租户'), findsNWidgets(2));

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));
    await tester.enterText(fields.at(0), '102');
    await tester.enterText(fields.at(1), '李四');
    await tester.enterText(fields.at(2), '1800');
    await tester.enterText(fields.at(3), '240');

    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(repo.tenants.length, 2, reason: '仓库里应有两个租户');
    expect(find.text('102 · 李四'), findsOneWidget, reason: '列表应显示新租户');
  });

  testWidgets('编辑租户：修改房租后保存生效', (WidgetTester tester) async {
    final BillRepository repo = await freshRepo(tenants: const <Tenant>[demo]);
    await pumpManage(tester, repo);

    await tester.tap(find.byTooltip('编辑'));
    await tester.pumpAndSettle();

    expect(find.text('编辑租户'), findsOneWidget);
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));
    await tester.enterText(fields.at(1), '张三丰');
    await tester.enterText(fields.at(2), '1600');

    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();

    expect(repo.tenants.length, 1, reason: '仍是同一租户（同 id 覆盖）');
    expect(repo.tenants.first.name, '张三丰');
    expect(repo.tenants.first.rent, 160000);
    expect(find.text('101 · 张三丰'), findsOneWidget);
  });

  testWidgets('删除租户：确认后删除且级联删除账单', (WidgetTester tester) async {
    final BillRepository repo = await freshRepo(tenants: const <Tenant>[demo]);
    await repo.saveBill(const Bill(
      id: 'b1',
      tenantId: 't1',
      year: 2026,
      month: 8,
      rent: 150000,
      propertyFee: 20000,
      waterFee: 0,
      electricityFee: 0,
      gasFee: 0,
      paid: false,
      note: '',
    ));
    await pumpManage(tester, repo);

    await tester.tap(find.byTooltip('删除'));
    await tester.pumpAndSettle();
    expect(find.text('删除租户'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(repo.tenants, isEmpty, reason: '租户被删除');
    expect(repo.bills, isEmpty, reason: '对应账单一并清除');
    expect(find.text('暂无租户，点右下角添加'), findsOneWidget);
  });
}

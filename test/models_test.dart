import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rent_book/data/datasources/bill_store.dart';
import 'package:rent_book/data/datasources/legacy_prefs_migration.dart';
import 'package:rent_book/data/repositories/bill_repository.dart';
import 'package:rent_book/domain/models/bill.dart';
import 'package:rent_book/domain/models/tenant.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const Tenant tenant = Tenant(
    id: 't1',
    name: '张三',
    room: '101',
    rent: 150000,
    propertyFee: 20000,
  );

  Bill makeBill({
    String id = 'b1',
    int year = 2026,
    int month = 9,
    int water = 3560,
    int electricity = 12045,
    int gas = 4800,
    bool paid = false,
  }) {
    return Bill(
      id: id,
      tenantId: 't1',
      year: year,
      month: month,
      rent: 150000,
      propertyFee: 20000,
      waterFee: water,
      electricityFee: electricity,
      gasFee: gas,
      paid: paid,
      note: '',
    );
  }

  group('模型 JSON 序列化', () {
    test('Tenant toJson/fromJson 往返一致', () {
      final Map<String, dynamic> json = tenant.toJson();
      final Tenant restored = Tenant.fromJson(json);
      expect(restored.id, tenant.id);
      expect(restored.name, tenant.name);
      expect(restored.room, tenant.room);
      expect(restored.rent, tenant.rent);
      expect(restored.propertyFee, tenant.propertyFee);
    });

    test('Bill toJson/fromJson 往返一致，且 total 计算正确', () {
      final Bill bill = makeBill();
      expect(bill.total, 150000 + 20000 + 3560 + 12045 + 4800);
      final Bill restored = Bill.fromJson(bill.toJson());
      expect(restored.id, bill.id);
      expect(restored.tenantId, bill.tenantId);
      expect(restored.year, bill.year);
      expect(restored.month, bill.month);
      expect(restored.waterFee, bill.waterFee);
      expect(restored.electricityFee, bill.electricityFee);
      expect(restored.gasFee, bill.gasFee);
      expect(restored.paid, bill.paid);
      expect(restored.note, bill.note);
    });

    test('copyForPeriod 换月份并清空收款状态', () {
      final Bill next = makeBill(paid: true)
          .copyForPeriod(2026, 10, newId: 'b2');
      expect(next.year, 2026);
      expect(next.month, 10);
      expect(next.id, 'b2');
      expect(next.paid, isFalse);
      expect(next.rent, 150000);
    });
  });

  group('BillRepository', () {
    test('保存账单、同月覆盖、按月合计', () async {
      final BillRepository repo = BillRepository(store: MemoryBillStore());
      await repo.load();
      await repo.saveTenant(tenant);

      await repo.saveBill(makeBill(id: 'b1'));
      await repo.saveBill(makeBill(id: 'b2')); // 同一租户同月 → 覆盖
      expect(repo.bills.length, 1);
      expect(repo.bills.first.id, 'b2');
      expect(repo.billFor('t1', 2026, 9)!.id, 'b2');
      expect(repo.totalForMonth(2026, 9), makeBill().total);

      // 下个月新账单
      await repo.saveBill(makeBill(id: 'b3', month: 10));
      expect(repo.bills.length, 2);
      // 最近一笔是 10 月的 b3（固定项带出来源）
      expect(repo.latestBillFor('t1')!.id, 'b3');
    });

    test('删除租户级联删除账单，且持久化到 store', () async {
      final MemoryBillStore store = MemoryBillStore();
      final BillRepository repo = BillRepository(store: store);
      await repo.load();
      await repo.saveTenant(tenant);
      await repo.saveBill(makeBill());

      await repo.deleteTenant('t1');
      expect(repo.tenants, isEmpty);
      expect(repo.bills, isEmpty);

      // 新仓库从同一个 store 读不到已删数据
      final BillRepository repo2 = BillRepository(store: store);
      await repo2.load();
      expect(repo2.tenants, isEmpty);
      expect(repo2.bills, isEmpty);
    });

    test('回归：从 store 加载已有数据后仍可增删改（定长列表缺陷）', () async {
      final MemoryBillStore store = MemoryBillStore();
      await store.open();
      await store.replaceAll(
        tenants: <Tenant>[tenant],
        bills: <Bill>[makeBill()],
      );

      final BillRepository repo = BillRepository(store: store);
      await repo.load();
      expect(repo.tenants.length, 1);
      expect(repo.bills.length, 1);

      // 此前 _decodeList 返回定长列表，以下每一行都会抛
      // "Cannot remove from a fixed-length list" / Unsupported operation。
      await repo.saveTenant(const Tenant(
          id: 't2', name: '李四', room: '102', rent: 1, propertyFee: 1));
      expect(repo.tenants.length, 2);

      await repo.setBillPaid('b1', paid: true);
      expect(repo.billFor('t1', 2026, 9)!.paid, isTrue);

      await repo.deleteBill('b1');
      expect(repo.bills, isEmpty);

      await repo.deleteTenant('t1');
      expect(repo.tenants.map((Tenant t) => t.id), <String>['t2']);

      // 再持久化一轮，确认新数据可写回并可重新加载。
      final BillRepository repo2 = BillRepository(store: store);
      await repo2.load();
      expect(repo2.tenants.map((Tenant t) => t.id), <String>['t2']);
      expect(repo2.bills, isEmpty);
    });

    test('视图缓存随写入刷新，且对外不可修改', () async {
      final BillRepository repo = BillRepository(store: MemoryBillStore());
      await repo.load();
      expect(repo.tenants, isEmpty);

      await repo.saveTenant(tenant);
      expect(repo.tenants.length, 1, reason: '写入后缓存应已刷新');
      expect(() => repo.tenants.add(tenant), throwsUnsupportedError);
    });
  });

  group('旧数据迁移', () {
    test('从 SharedPreferences JSON 迁移到 store，并清除旧键', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        kLegacyTenantsKey:
            jsonEncode(<Map<String, dynamic>>[tenant.toJson()]),
        kLegacyBillsKey:
            jsonEncode(<Map<String, dynamic>>[makeBill().toJson()]),
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final MemoryBillStore store = MemoryBillStore();

      final bool migrated =
          await migrateLegacyPrefs(prefs: prefs, store: store);
      expect(migrated, isTrue);
      expect((await store.loadTenants()).length, 1);
      expect((await store.loadBills()).length, 1);
      expect(prefs.getString(kLegacyTenantsKey), isNull);
      expect(prefs.getString(kLegacyBillsKey), isNull);

      // 再次迁移应为 no-op，不会重复导入。
      expect(await migrateLegacyPrefs(prefs: prefs, store: store), isFalse);
    });
  });
}

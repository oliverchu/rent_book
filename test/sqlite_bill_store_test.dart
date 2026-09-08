import 'package:flutter_test/flutter_test.dart';
import 'package:rent_book/data/datasources/sqlite_bill_store.dart';
import 'package:rent_book/domain/models/bill.dart';
import 'package:rent_book/domain/models/tenant.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const Tenant tenant = Tenant(
  id: 't1',
  name: '张三',
  room: '101',
  rent: 150000,
  propertyFee: 20000,
);

Bill makeBill({String id = 'b1', String tenantId = 't1', int month = 9}) => Bill(
      id: id,
      tenantId: tenantId,
      year: 2026,
      month: month,
      rent: 150000,
      propertyFee: 20000,
      waterFee: 3560,
      electricityFee: 12045,
      gasFee: 4800,
      paid: false,
      note: '测试备注',
    );

void main() {
  // 在 VM 上用 sqlite3 的 FFI 实现跑真实的 SQLite 语句。
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late SqliteBillStore store;

  setUp(() async {
    store = SqliteBillStore(databasePath: inMemoryDatabasePath);
    await store.open();
  });

  tearDown(() => store.close());

  test('租户与账单可写入并完整读回（含布尔与中文备注）', () async {
    await store.upsertTenant(tenant);
    await store.upsertBill(makeBill());

    final List<Tenant> tenants = await store.loadTenants();
    expect(tenants.length, 1);
    expect(tenants.first.name, '张三');
    expect(tenants.first.rent, 150000);
    expect(tenants.first.propertyFee, 20000);

    final List<Bill> bills = await store.loadBills();
    expect(bills.length, 1);
    final Bill bill = bills.first;
    expect(bill.tenantId, 't1');
    expect(bill.year, 2026);
    expect(bill.month, 9);
    expect(bill.waterFee, 3560);
    expect(bill.electricityFee, 12045);
    expect(bill.gasFee, 4800);
    expect(bill.paid, isFalse);
    expect(bill.note, '测试备注');
  });

  test('同一租户同一月份只保留一条账单（UNIQUE 冲突替换）', () async {
    await store.upsertTenant(tenant);
    await store.upsertBill(makeBill(id: 'b1'));
    await store.upsertBill(makeBill(id: 'b2'));

    final List<Bill> bills = await store.loadBills();
    expect(bills.length, 1);
    expect(bills.first.id, 'b2', reason: '后写入的账单应替换掉同月旧账单');
  });

  test('paid 字段往返为布尔值', () async {
    await store.upsertTenant(tenant);
    await store.upsertBill(makeBill().copyWith(paid: true));
    expect((await store.loadBills()).first.paid, isTrue);
  });

  test('删除租户时外键级联删除其账单', () async {
    await store.upsertTenant(tenant);
    await store.upsertBill(makeBill());
    await store.deleteTenant('t1');

    expect(await store.loadTenants(), isEmpty);
    expect(await store.loadBills(), isEmpty, reason: 'ON DELETE CASCADE 应生效');
  });

  test('replaceAll 清空后写入，clear 清空全部', () async {
    await store.upsertTenant(tenant);
    await store.upsertBill(makeBill());

    const Tenant other = Tenant(
      id: 't9',
      name: '李四',
      room: '102',
      rent: 1,
      propertyFee: 2,
    );
    await store.replaceAll(
      tenants: <Tenant>[other],
      bills: <Bill>[makeBill(id: 'b9', tenantId: 't9', month: 10)],
    );
    final List<Tenant> tenants = await store.loadTenants();
    expect(tenants.length, 1);
    expect(tenants.first.id, 't9');
    final List<Bill> bills = await store.loadBills();
    expect(bills.length, 1);
    expect(bills.first.tenantId, 't9');

    await store.clear();
    expect(await store.loadTenants(), isEmpty);
    expect(await store.loadBills(), isEmpty);
  });
}

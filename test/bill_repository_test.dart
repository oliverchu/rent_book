import 'package:flutter_test/flutter_test.dart';
import 'package:rent_book/data/datasources/bill_store.dart';
import 'package:rent_book/data/repositories/bill_repository.dart';
import 'package:rent_book/domain/models/bill.dart';
import 'package:rent_book/domain/models/tenant.dart';

/// 回归：`SqliteBillStore.load*` 返回 `growable: false` 的定长列表。
/// 仓储若直接缓存这些列表，后续 `save*` 会抛
/// "Unsupported operation: Cannot add to a fixed-length list"。
class _FixedLengthStore extends MemoryBillStore {
  @override
  Future<List<Tenant>> loadTenants() async =>
      List<Tenant>.of(await super.loadTenants(), growable: false);

  @override
  Future<List<Bill>> loadBills() async =>
      List<Bill>.of(await super.loadBills(), growable: false);
}

void main() {
  test('仓储在 load 后仍可新增租户与账单（兼容定长列表 Store）', () async {
    final BillRepository repo = BillRepository(store: _FixedLengthStore());
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
      year: 2026,
      month: 9,
      rent: 150000,
      propertyFee: 20000,
      waterFee: 3560,
      electricityFee: 12045,
      gasFee: 4800,
      paid: false,
      note: '',
    ));

    expect(repo.tenants, hasLength(1));
    expect(repo.bills, hasLength(1));
  });
}

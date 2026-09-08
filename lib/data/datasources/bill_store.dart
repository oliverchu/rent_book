import '../../domain/models/bill.dart';
import '../../domain/models/tenant.dart';

/// 租户 / 账单的持久化接口。
///
/// 生产实现是 SQLite（见 `sqlite_bill_store.dart`）；
/// 单元测试可用 [MemoryBillStore]，免去数据库运行时依赖。
abstract class BillStore {
  /// 打开底层资源（连接数据库 / 建表）。
  Future<void> open();

  Future<List<Tenant>> loadTenants();

  Future<List<Bill>> loadBills();

  /// 新增或覆盖同 id 的租户。
  Future<void> upsertTenant(Tenant tenant);

  /// 删除租户及其全部账单。
  Future<void> deleteTenant(String id);

  /// 新增或覆盖账单；同一租户同一月份只保留一条。
  Future<void> upsertBill(Bill bill);

  Future<void> deleteBill(String id);

  /// 清空后写入给定数据（旧数据迁移 / 导入用）。
  Future<void> replaceAll({
    required List<Tenant> tenants,
    required List<Bill> bills,
  });

  /// 清空全部数据。
  Future<void> clear();

  Future<void> close();
}

/// 内存实现：仅用于测试。
class MemoryBillStore implements BillStore {
  final Map<String, Tenant> _tenants = <String, Tenant>{};
  final Map<String, Bill> _bills = <String, Bill>{};

  @override
  Future<void> open() async {}

  @override
  Future<List<Tenant>> loadTenants() async => _tenants.values.toList();

  @override
  Future<List<Bill>> loadBills() async => _bills.values.toList();

  @override
  Future<void> upsertTenant(Tenant tenant) async {
    _tenants[tenant.id] = tenant;
  }

  @override
  Future<void> deleteTenant(String id) async {
    _tenants.remove(id);
    _bills.removeWhere((_, Bill b) => b.tenantId == id);
  }

  @override
  Future<void> upsertBill(Bill bill) async {
    _bills.removeWhere(
      (_, Bill b) =>
          b.id != bill.id &&
          b.tenantId == bill.tenantId &&
          b.year == bill.year &&
          b.month == bill.month,
    );
    _bills[bill.id] = bill;
  }

  @override
  Future<void> deleteBill(String id) async {
    _bills.remove(id);
  }

  @override
  Future<void> replaceAll({
    required List<Tenant> tenants,
    required List<Bill> bills,
  }) async {
    _tenants
      ..clear()
      ..addEntries(tenants.map((Tenant t) => MapEntry<String, Tenant>(t.id, t)));
    _bills
      ..clear()
      ..addEntries(bills.map((Bill b) => MapEntry<String, Bill>(b.id, b)));
  }

  @override
  Future<void> clear() async {
    _tenants.clear();
    _bills.clear();
  }

  @override
  Future<void> close() async {}
}

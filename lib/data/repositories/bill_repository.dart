import 'package:flutter/foundation.dart';

import '../../domain/models/bill.dart';
import '../../domain/models/tenant.dart';
import '../datasources/bill_store.dart';

/// 应用内唯一数据源：内存缓存 + [BillStore] 持久化。
///
/// 读取走内存（同步 getter），写入异步落库后 [notifyListeners]。
class BillRepository extends ChangeNotifier {
  // Dart 不允许命名参数直接初始化私有字段，故显式赋值。
  // ignore: prefer_initializing_formals
  BillRepository({required BillStore store}) : _store = store;

  final BillStore _store;

  List<Tenant> _tenants = <Tenant>[];
  List<Bill> _bills = <Bill>[];

  // 缓存不可变视图，避免每次读取 getter 都重新复制一份列表。
  List<Tenant> _tenantsView = const <Tenant>[];
  List<Bill> _billsView = const <Bill>[];

  List<Tenant> get tenants => _tenantsView;

  List<Bill> get bills => _billsView;

  Future<void> load() async {
    // Store 可能返回定长列表（如 SqliteBillStore 的 `growable: false`），
    // 而仓储需要可变缓存，这里复制一份再保存。
    _tenants = List<Tenant>.of(await _store.loadTenants());
    _bills = List<Bill>.of(await _store.loadBills());
    _sortTenants();
    _refreshViews();
    notifyListeners();
  }

  Tenant? tenantById(String id) {
    for (final Tenant t in _tenants) {
      if (t.id == id) {
        return t;
      }
    }
    return null;
  }

  Bill? billFor(String tenantId, int year, int month) {
    for (final Bill b in _bills) {
      if (b.tenantId == tenantId && b.year == year && b.month == month) {
        return b;
      }
    }
    return null;
  }

  /// 该租户最近一笔账单（用于把固定支出带到新月份）。
  ///
  /// 传 [beforePeriodKey] 时只考虑不晚于该期的账单，
  /// 避免预录了未来月份的账单被错误带出。
  Bill? latestBillFor(String tenantId, {int? beforePeriodKey}) {
    Bill? latest;
    for (final Bill b in _bills) {
      if (b.tenantId != tenantId) {
        continue;
      }
      if (beforePeriodKey != null && b.periodKey > beforePeriodKey) {
        continue;
      }
      if (latest == null || b.periodKey > latest.periodKey) {
        latest = b;
      }
    }
    return latest;
  }

  Future<void> saveTenant(Tenant tenant) async {
    final int index = _tenants.indexWhere((Tenant t) => t.id == tenant.id);
    if (index >= 0) {
      _tenants[index] = tenant;
    } else {
      _tenants.add(tenant);
    }
    _sortTenants();
    await _store.upsertTenant(tenant);
    _refreshViews();
    notifyListeners();
  }

  Future<void> deleteTenant(String id) async {
    _tenants.removeWhere((Tenant t) => t.id == id);
    _bills.removeWhere((Bill b) => b.tenantId == id);
    await _store.deleteTenant(id);
    _refreshViews();
    notifyListeners();
  }

  Future<void> saveBill(Bill bill) async {
    // 同一租户同一月份只保留一条账单。
    _bills.removeWhere(
      (Bill b) =>
          b.id != bill.id &&
          b.tenantId == bill.tenantId &&
          b.year == bill.year &&
          b.month == bill.month,
    );
    final int index = _bills.indexWhere((Bill b) => b.id == bill.id);
    if (index >= 0) {
      _bills[index] = bill;
    } else {
      _bills.add(bill);
    }
    await _store.upsertBill(bill);
    _refreshViews();
    notifyListeners();
  }

  Future<void> setBillPaid(String id, {required bool paid}) async {
    final int index = _bills.indexWhere((Bill b) => b.id == id);
    if (index < 0) {
      return;
    }
    final Bill updated = _bills[index].copyWith(paid: paid);
    _bills[index] = updated;
    await _store.upsertBill(updated);
    _refreshViews();
    notifyListeners();
  }

  Future<void> deleteBill(String id) async {
    _bills.removeWhere((Bill b) => b.id == id);
    await _store.deleteBill(id);
    _refreshViews();
    notifyListeners();
  }

  int totalForMonth(int year, int month) {
    int sum = 0;
    for (final Bill b in _bills) {
      if (b.year == year && b.month == month) {
        sum += b.total;
      }
    }
    return sum;
  }

  List<Bill> billsForMonth(int year, int month) {
    return _bills
        .where((Bill b) => b.year == year && b.month == month)
        .toList(growable: false);
  }

  void _sortTenants() {
    _tenants.sort((Tenant a, Tenant b) {
      final int byRoom = a.room.compareTo(b.room);
      if (byRoom != 0) {
        return byRoom;
      }
      return a.name.compareTo(b.name);
    });
  }

  void _refreshViews() {
    _tenantsView = List<Tenant>.unmodifiable(_tenants);
    _billsView = List<Bill>.unmodifiable(_bills);
  }

  /// 清空全部数据（忘记密码时使用）。
  Future<void> clearAll() async {
    _tenants = <Tenant>[];
    _bills = <Bill>[];
    await _store.clear();
    _refreshViews();
    notifyListeners();
  }
}

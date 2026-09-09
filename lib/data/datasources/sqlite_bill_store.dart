import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../domain/models/bill.dart';
import '../../domain/models/tenant.dart';
import 'bill_store.dart';

/// SQLite 持久化实现。
///
/// 相比旧版「SharedPreferences 存整份 JSON、每次全量重写」，
/// 这里按行读写，写入与启动成本都是 O(变更量) 而非 O(全量)。
class SqliteBillStore implements BillStore {
  SqliteBillStore({this.databaseName = 'rent_book.db', this.databasePath});

  static const int _version = 1;
  static const String _tenantsTable = 'tenants';
  static const String _billsTable = 'bills';

  final String databaseName;

  /// 显式指定数据库文件路径（测试用内存库）；为空时用 `getDatabasesPath()/databaseName`。
  final String? databasePath;

  Database? _db;

  Database get _database {
    final Database? db = _db;
    if (db == null) {
      throw StateError('BillStore 尚未打开，请先调用 open()');
    }
    return db;
  }

  @override
  Future<void> open() async {
    if (_db != null) {
      return;
    }
    final String path =
        databasePath ?? p.join(await getDatabasesPath(), databaseName);
    _db = await openDatabase(
      path,
      version: _version,
      onConfigure: (Database db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tenantsTable (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            room TEXT NOT NULL,
            rent_cents INTEGER NOT NULL,
            property_fee_cents INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $_billsTable (
            id TEXT PRIMARY KEY,
            tenant_id TEXT NOT NULL,
            year INTEGER NOT NULL,
            month INTEGER NOT NULL,
            rent_cents INTEGER NOT NULL,
            property_fee_cents INTEGER NOT NULL,
            water_fee_cents INTEGER NOT NULL,
            electricity_fee_cents INTEGER NOT NULL,
            gas_fee_cents INTEGER NOT NULL,
            paid INTEGER NOT NULL,
            note TEXT NOT NULL,
            UNIQUE (tenant_id, year, month),
            FOREIGN KEY (tenant_id) REFERENCES $_tenantsTable (id)
              ON DELETE CASCADE
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_bills_period ON $_billsTable (year, month)',
        );
      },
    );
  }

  @override
  Future<List<Tenant>> loadTenants() async {
    final List<Map<String, Object?>> rows =
        await _database.query(_tenantsTable, orderBy: 'room, name');
    return rows.map(_tenantFromRow).toList(growable: false);
  }

  @override
  Future<List<Bill>> loadBills() async {
    final List<Map<String, Object?>> rows =
        await _database.query(_billsTable, orderBy: 'year, month');
    return rows.map(_billFromRow).toList(growable: false);
  }

  @override
  Future<void> upsertTenant(Tenant tenant) async {
    await _database.insert(
      _tenantsTable,
      _tenantToRow(tenant),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTenant(String id) async {
    // 外键 ON DELETE CASCADE 会一并清除该租户的账单。
    await _database.delete(_tenantsTable, where: 'id = ?', whereArgs: <Object>[id]);
  }

  @override
  Future<void> upsertBill(Bill bill) async {
    await _database.insert(
      _billsTable,
      _billToRow(bill),
      // UNIQUE(tenant_id, year, month) 冲突时替换掉旧行。
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteBill(String id) async {
    await _database.delete(_billsTable, where: 'id = ?', whereArgs: <Object>[id]);
  }

  @override
  Future<void> replaceAll({
    required List<Tenant> tenants,
    required List<Bill> bills,
  }) async {
    await _database.transaction((Transaction txn) async {
      await txn.delete(_billsTable);
      await txn.delete(_tenantsTable);
      for (final Tenant tenant in tenants) {
        await txn.insert(
          _tenantsTable,
          _tenantToRow(tenant),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final Bill bill in bills) {
        await txn.insert(
          _billsTable,
          _billToRow(bill),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> clear() async {
    await _database.transaction((Transaction txn) async {
      await txn.delete(_billsTable);
      await txn.delete(_tenantsTable);
    });
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  static Tenant _tenantFromRow(Map<String, Object?> row) => Tenant(
        id: row['id']! as String,
        name: row['name']! as String,
        room: row['room']! as String,
        rent: (row['rent_cents']! as num).toInt(),
        propertyFee: (row['property_fee_cents']! as num).toInt(),
      );

  static Map<String, Object?> _tenantToRow(Tenant tenant) => <String, Object?>{
        'id': tenant.id,
        'name': tenant.name,
        'room': tenant.room,
        'rent_cents': tenant.rent,
        'property_fee_cents': tenant.propertyFee,
      };

  static Bill _billFromRow(Map<String, Object?> row) => Bill(
        id: row['id']! as String,
        tenantId: row['tenant_id']! as String,
        year: (row['year']! as num).toInt(),
        month: (row['month']! as num).toInt(),
        rent: (row['rent_cents']! as num).toInt(),
        propertyFee: (row['property_fee_cents']! as num).toInt(),
        waterFee: (row['water_fee_cents']! as num).toInt(),
        electricityFee: (row['electricity_fee_cents']! as num).toInt(),
        gasFee: (row['gas_fee_cents']! as num).toInt(),
        paid: (row['paid']! as num).toInt() == 1,
        note: row['note']! as String,
      );

  static Map<String, Object?> _billToRow(Bill bill) => <String, Object?>{
        'id': bill.id,
        'tenant_id': bill.tenantId,
        'year': bill.year,
        'month': bill.month,
        'rent_cents': bill.rent,
        'property_fee_cents': bill.propertyFee,
        'water_fee_cents': bill.waterFee,
        'electricity_fee_cents': bill.electricityFee,
        'gas_fee_cents': bill.gasFee,
        'paid': bill.paid ? 1 : 0,
        'note': bill.note,
      };
}

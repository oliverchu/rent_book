import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:rent_book/data/datasources/sqlite_bill_store.dart';
import 'package:rent_book/data/datasources/sqflite_platform_init.dart';
import 'package:rent_book/domain/models/tenant.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // 回归：Windows 桌面上 sqflite 没有原生插件，
  // 若不先初始化 FFI 实现，main() 会在打开数据库时崩溃
  // "Bad state: databaseFactory not initialized"。
  test('桌面平台初始化后可在默认目录打开数据库', () async {
    if (!Platform.isWindows && !Platform.isLinux) {
      return; // 仅 Windows / Linux 需要 FFI 兜底
    }
    initSqfliteForCurrentPlatform();

    final String path =
        p.join(await getDatabasesPath(), 'rent_book_platform_test.db');
    await databaseFactory.deleteDatabase(path);
    addTearDown(() => databaseFactory.deleteDatabase(path));

    final SqliteBillStore store = SqliteBillStore(databasePath: path);
    await store.open();
    addTearDown(store.close);

    await store.upsertTenant(const Tenant(
      id: 't1',
      name: '张三',
      room: '101',
      rent: 150000,
      propertyFee: 20000,
    ));
    expect(await store.loadTenants(), hasLength(1));
  });
}

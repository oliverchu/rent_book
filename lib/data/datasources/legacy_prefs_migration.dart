import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/bill.dart';
import '../../domain/models/tenant.dart';
import 'bill_store.dart';

/// 旧版 SharedPreferences 中存放数据的键。
const String kLegacyTenantsKey = 'rent_book.tenants';
const String kLegacyBillsKey = 'rent_book.bills';

/// 把旧版 SharedPreferences 里的 JSON 数据一次性导入 [store]。
///
/// 仅在旧键存在时执行；导入后删除旧键，避免重复迁移。
/// 返回是否真的迁移了数据。
Future<bool> migrateLegacyPrefs({
  required SharedPreferences prefs,
  required BillStore store,
}) async {
  final String? rawTenants = prefs.getString(kLegacyTenantsKey);
  final String? rawBills = prefs.getString(kLegacyBillsKey);
  if ((rawTenants == null || rawTenants.isEmpty) &&
      (rawBills == null || rawBills.isEmpty)) {
    return false;
  }
  final List<Tenant> tenants = _decodeList(rawTenants, Tenant.fromJson);
  final List<Bill> bills = _decodeList(rawBills, Bill.fromJson);
  final bool migrated = tenants.isNotEmpty || bills.isNotEmpty;
  if (migrated) {
    await store.replaceAll(tenants: tenants, bills: bills);
  }
  await prefs.remove(kLegacyTenantsKey);
  await prefs.remove(kLegacyBillsKey);
  return migrated;
}

/// 单条解析失败时跳过该条而不是整体抛异常，避免一条坏数据阻断迁移。
List<T> _decodeList<T>(
  String? raw,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (raw == null || raw.isEmpty) {
    return <T>[];
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    return <T>[];
  }
  if (decoded is! List<Object?>) {
    return <T>[];
  }
  final List<T> result = <T>[];
  for (final Object? item in decoded) {
    if (item is! Map<String, dynamic>) {
      continue;
    }
    try {
      result.add(fromJson(item));
    } on FormatException catch (e) {
      debugPrint('跳过无法解析的旧记录：$e');
    }
  }
  return result;
}

import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 初始化当前平台所需的 SQLite 实现。
///
/// `sqflite` 只在 Android / iOS / macOS 提供原生插件；
/// Windows / Linux 桌面没有该插件，必须改用 FFI 实现。
/// 必须在任何数据库调用之前执行。
void initSqfliteForCurrentPlatform() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

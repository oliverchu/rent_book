import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 迭代哈希：bytes = SHA256 反复作用于初始输入 [iterations] 轮。
///
/// 声明为顶层函数，便于在独立 isolate 中执行（闭包捕获的均为可发送值）。
String _stretchSync(String salt, String password, int iterations) {
  List<int> bytes = utf8.encode('$salt:$password');
  for (int i = 0; i < iterations; i++) {
    bytes = sha256.convert(bytes).bytes;
  }
  return _toHex(bytes);
}

/// 旧版（v1）单次哈希：sha256(salt:password)。仅为兼容存量数据保留。
String _legacyHashSync(String salt, String password) =>
    sha256.convert(utf8.encode('$salt:$password')).toString();

String _toHex(List<int> bytes) =>
    bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();

/// 哈希计算执行器。默认在独立 isolate 中运行；
/// 测试可注入同步实现，避免与 widget 测试的 fake async 冲突。
typedef ComputeFn = Future<R> Function<R>(R Function() computation);

/// 启动密码服务：只存"方案$参数$盐$哈希"，不存明文。
///
/// 新格式为迭代加盐 SHA256（key stretching），默认迭代 [_iterations] 次，
/// 大幅抬高低成本密码被离线暴力破解的代价；
/// 旧版"单次 SHA256"格式在校验成功后会自动升级为新格式。
///
/// 所有哈希计算都在独立 isolate 中完成，避免阻塞 UI 线程。
class PasswordService {
  PasswordService(this._prefs, {ComputeFn? compute})
      : _compute = compute ?? Isolate.run;

  static const String _key = 'rent_book.password';
  static const int minLength = 4;

  /// 存储格式标签，便于未来替换算法或调整参数。
  static const String _schemeTag = 'pbkdf2-sha256';

  /// 迭代轮数：对登录体验无感，却能把每秒尝试次数压低若干个数量级。
  static const int _iterations = 20000;

  final SharedPreferences _prefs;
  final ComputeFn _compute;
  final Random _random = Random.secure();

  bool get hasPassword => (_prefs.getString(_key) ?? '').isNotEmpty;

  /// 校验输入是否为当前密码。未设置过密码时返回 false。
  Future<bool> verify(String input) async {
    final String? stored = _prefs.getString(_key);
    if (stored == null || stored.isEmpty) {
      return false;
    }
    final List<String> parts = stored.split(r'$');
    if (parts.length == 4 && parts[0] == _schemeTag) {
      final int? iterations = int.tryParse(parts[1]);
      if (iterations == null || iterations <= 0) {
        return false; // 参数损坏视为不匹配
      }
      final String computed = await _compute(
        () => _stretchSync(parts[2], input, iterations),
      );
      return _constantTimeEquals(computed, parts[3]);
    }
    if (parts.length == 2) {
      // 旧版单次哈希：校验通过后透明升级到拉伸格式。
      final String computed = await _compute(
        () => _legacyHashSync(parts[0], input),
      );
      final bool ok = _constantTimeEquals(computed, parts[1]);
      if (ok) {
        await _store(input);
      }
      return ok;
    }
    return false; // 格式损坏视为不匹配
  }

  Future<void> setPassword(String password) => _store(password);

  Future<void> _store(String password) async {
    final String salt = _randomSalt();
    final String hash = await _compute(
      () => _stretchSync(salt, password, _iterations),
    );
    final String record = <String>[
      _schemeTag,
      '$_iterations',
      salt,
      hash,
    ].join(r'$');
    await _prefs.setString(_key, record);
  }

  String _randomSalt() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List<String>.generate(
      16,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// 恒定时间比较，避免逐字符短路的时序侧信道。
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }
    int diff = 0;
    for (int i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// 清除密码（忘记密码重置时使用，需与数据清空配合）。
  Future<void> clear() => _prefs.remove(_key);
}

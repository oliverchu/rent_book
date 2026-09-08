import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/currency.dart';

/// 应用级设置：语言与货币。
///
/// - 语言为 `null` 时跟随系统。
/// - 货币为 `null` 时跟随当前语言（见 [Currency.forLanguage]）。
class AppSettings extends ChangeNotifier {
  /// [prefs] 为 `null` 时设置仅保存在内存中（测试用）。
  AppSettings({SharedPreferences? prefs}) {
    _prefs = prefs;
    final String? localeCode = _prefs?.getString(_localeKey);
    _locale = localeCode == null ? null : Locale(localeCode);
    final String? currencyCode = _prefs?.getString(_currencyKey);
    _currencyOverride =
        currencyCode == null ? null : Currency.fromCode(currencyCode);
  }

  static const String _localeKey = 'rent_book.locale';
  static const String _currencyKey = 'rent_book.currency';

  late final SharedPreferences? _prefs;

  Locale? _locale;
  Currency? _currencyOverride;

  /// 语言覆盖；`null` 表示跟随系统。
  Locale? get locale => _locale;

  /// 货币覆盖；`null` 表示跟随语言。
  Currency? get currencyOverride => _currencyOverride;

  /// [locale] 下实际使用的货币。
  Currency currencyFor(Locale locale) =>
      _currencyOverride ?? Currency.forLanguage(locale.languageCode);

  /// 设置语言；传 `null` 恢复跟随系统。
  void setLocale(Locale? locale) {
    if (_locale == locale) {
      return;
    }
    _locale = locale;
    notifyListeners();
    if (locale == null) {
      _prefs?.remove(_localeKey);
    } else {
      _prefs?.setString(_localeKey, locale.languageCode);
    }
  }

  /// 设置货币；传 `null` 恢复跟随语言。
  void setCurrency(Currency? currency) {
    if (_currencyOverride == currency) {
      return;
    }
    _currencyOverride = currency;
    notifyListeners();
    if (currency == null) {
      _prefs?.remove(_currencyKey);
    } else {
      _prefs?.setString(_currencyKey, currency.code);
    }
  }
}

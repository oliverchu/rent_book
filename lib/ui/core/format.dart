/// 金额与日期的展示格式化。
///
/// 金额一律以“分”（int）表示。
library;

import 'package:intl/intl.dart';

import '../../domain/models/currency.dart';

/// 按币种的小数位与千分位格式化数字。
///
/// 123450 + CNY -> "1,234.50"；123450 + JPY -> "1,235"。
String formatNumber(int cents, Currency currency) {
  final bool negative = cents < 0;
  final int abs = cents.abs();
  final int units;
  final String fracPart;
  if (currency.decimalDigits == 0) {
    units = (abs / 100).round();
    fracPart = '';
  } else {
    units = abs ~/ 100;
    fracPart = (abs % 100).toString().padLeft(2, '0');
  }
  final String grouped = _groupThousands(units.toString());
  return '${negative ? '-' : ''}$grouped${fracPart.isEmpty ? '' : '.$fracPart'}';
}

/// 金额 + 货币符号（无空格），如 `¥1,234.50`。
String formatMoney(int cents, Currency currency) =>
    '${currency.symbol}${formatNumber(cents, currency)}';

/// 123450 -> "1,234.50"（人民币）。
String yuan(int cents) => formatNumber(cents, Currency.cny);

String _groupThousands(String digits) {
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final int remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && (remaining - 1) % 3 == 0) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

/// 按月显示的年月标签，随 [localeName] 变化。
///
/// - `zh` / `ja`：`2026年9月`
/// - `en`：`September 2026`
/// - `ko`：`2026년 9월`
String monthLabel(int year, int month, String localeName) =>
    DateFormat.yMMMM(localeName).format(DateTime(year, month));

/// 图表横轴用的短月份标签，随 [localeName] 变化。
///
/// - `zh` / `ja`：`9月`
/// - `en`：`Sep`
/// - `ko`：`9월`
String shortMonthLabel(int month, String localeName) =>
    DateFormat.MMM(localeName).format(DateTime(2000, month));

/// 2026-09-01
String fullDate(DateTime date) {
  final String m = date.month.toString().padLeft(2, '0');
  final String d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}

/// 宽容地把输入框内容解析为金额（分），非法时返回 0。
int parseMoney(String input) {
  final double? value = double.tryParse(input.trim().replaceAll(',', ''));
  if (value == null) {
    return 0;
  }
  return (value * 100).round();
}

/// 把金额放回输入框时的简洁形式：整数不带小数位。
String moneyToText(int cents) {
  if (cents % 100 == 0) {
    return (cents ~/ 100).toString();
  }
  return (cents / 100).toStringAsFixed(2);
}

/// 应用支持的币种。
///
/// 金额在数据库中统一以「分」（1/100）存储，展示时按币种的小数位格式化。
enum Currency {
  /// 人民币：`¥`，2 位小数。
  cny(code: 'CNY', symbol: '¥', decimalDigits: 2),

  /// 美元：`$`，2 位小数。
  usd(code: 'USD', symbol: r'$', decimalDigits: 2),

  /// 日元：`¥`，无小数位。
  jpy(code: 'JPY', symbol: '¥', decimalDigits: 0),

  /// 韩元：`₩`，无小数位。
  krw(code: 'KRW', symbol: '₩', decimalDigits: 0);

  const Currency({
    required this.code,
    required this.symbol,
    required this.decimalDigits,
  });

  /// ISO 4217 货币代码，如 `CNY`。
  final String code;

  /// 展示用货币符号，如 `¥`。
  final String symbol;

  /// 展示的小数位数。
  final int decimalDigits;

  /// 按货币代码解析，未知或为空时回退到 [Currency.cny]。
  static Currency fromCode(String? code) => values.firstWhere(
        (Currency c) => c.code == code,
        orElse: () => Currency.cny,
      );

  /// 语言对应的默认币种：`en`→美元，`zh`→人民币，`ja`→日元，`ko`→韩元。
  static Currency forLanguage(String languageCode) => switch (languageCode) {
        'en' => Currency.usd,
        'ja' => Currency.jpy,
        'ko' => Currency.krw,
        _ => Currency.cny,
      };
}

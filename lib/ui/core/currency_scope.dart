import 'package:flutter/widgets.dart';

import '../../domain/models/currency.dart';

/// 向下传递当前货币。
///
/// 未包裹时回退到当前语言对应的默认币种，方便单独测试某个组件。
class CurrencyScope extends InheritedWidget {
  const CurrencyScope({
    super.key,
    required this.currency,
    required super.child,
  });

  /// 当前生效的货币。
  final Currency currency;

  /// 取当前货币；无 [CurrencyScope] 时按语言回退。
  static Currency of(BuildContext context) {
    final CurrencyScope? scope =
        context.dependOnInheritedWidgetOfExactType<CurrencyScope>();
    return scope?.currency ??
        Currency.forLanguage(Localizations.localeOf(context).languageCode);
  }

  @override
  bool updateShouldNotify(CurrencyScope oldWidget) =>
      currency != oldWidget.currency;
}

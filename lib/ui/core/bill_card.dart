import 'package:flutter/material.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../domain/models/bill.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/tenant.dart';
import 'currency_scope.dart';
import 'format.dart';

/// 用于导出图片的账单卡片（微信发送用）。
///
/// 外层使用 [RepaintBoundary] 包裹后即可截图为 PNG。
class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.bill,
    required this.tenant,
    this.issuedOn,
  });

  final Bill bill;
  final Tenant tenant;

  /// 出具日期，默认今天。
  final DateTime? issuedOn;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    final DateTime issued = issuedOn ?? DateTime.now();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 360,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, l10n),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      Text(l10n.billCardTenantLabel, style: _labelStyle),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${tenant.room}  ${tenant.name}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 4),
                  _feeRow(l10n.feeRent, bill.rent, currency),
                  _feeRow(l10n.feeProperty, bill.propertyFee, currency),
                  _feeRow(l10n.feeWater, bill.waterFee, currency),
                  _feeRow(l10n.feeElectricity, bill.electricityFee, currency),
                  _feeRow(l10n.feeGas, bill.gasFee, currency),
                  const SizedBox(height: 4),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(l10n.billCardTotalLabel, style: _totalLabelStyle),
                      const Spacer(),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${currency.symbol} ${formatNumber(bill.total, currency)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (bill.note.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(l10n.billCardNote(bill.note), style: _noteStyle),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Flexible(
                          child: Text(l10n.billCardIssuedOn(fullDate(issued)),
                              overflow: TextOverflow.ellipsis,
                              style: _noteStyle),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFF999999),
  );

  static const TextStyle _rowStyle = TextStyle(
    fontSize: 15,
    color: Color(0xFF444444),
  );

  static const TextStyle _totalLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF222222),
  );

  static const TextStyle _noteStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFFAAAAAA),
  );

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF00897B), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            l10n.billCardTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            monthLabel(
              bill.year,
              bill.month,
              Localizations.localeOf(context).toString(),
            ),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withAlpha(230),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, int cents, Currency currency) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Text(label, style: _rowStyle),
          const Spacer(),
          Text('${currency.symbol} ${formatNumber(cents, currency)}',
              style: _rowStyle),
        ],
      ),
    );
  }
}

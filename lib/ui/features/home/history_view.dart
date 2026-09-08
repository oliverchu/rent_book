import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../../data/repositories/bill_repository.dart';
import '../../../domain/models/bill.dart';
import '../../../domain/models/currency.dart';
import '../../../domain/models/tenant.dart';
import '../../core/currency_scope.dart';
import '../../core/format.dart';
import '../../router/app_router.dart';

/// 历史记录：按月份倒序分组展示所有账单。
class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BillRepository repository = context.watch<BillRepository>();
    final List<Bill> bills = repository.bills.toList()
      ..sort((Bill a, Bill b) => b.periodKey.compareTo(a.periodKey));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: bills.isEmpty
          ? Center(child: Text(l10n.historyEmpty))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: _groupByPeriod(bills).length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildGroup(context, _groupByPeriod(bills)[index]),
            ),
    );
  }

  /// 按 periodKey 分组，输入需已按月倒序。
  List<List<Bill>> _groupByPeriod(List<Bill> bills) {
    final List<List<Bill>> groups = <List<Bill>>[];
    for (final Bill b in bills) {
      if (groups.isEmpty || groups.last.first.periodKey != b.periodKey) {
        groups.add(<Bill>[b]);
      } else {
        groups.last.add(b);
      }
    }
    return groups;
  }

  Widget _buildGroup(BuildContext context, List<Bill> group) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    final BillRepository repository = context.read<BillRepository>();
    final Bill first = group.first;
    int monthTotal = 0;
    int paidTotal = 0;
    for (final Bill b in group) {
      monthTotal += b.total;
      if (b.paid) {
        paidTotal += b.total;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withAlpha(120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: <Widget>[
              Text(
                  monthLabel(first.year, first.month,
                      Localizations.localeOf(context).toString()),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(l10n.historyMonthTotal(formatMoney(monthTotal, currency))),
              if (paidTotal > 0) ...<Widget>[
                const SizedBox(width: 8),
                Text(l10n.commonReceivedAmount(formatMoney(paidTotal, currency)),
                    style: TextStyle(color: Colors.green.shade700)),
              ],
            ],
          ),
        ),
        for (final Bill b in group)
          ListTile(
            leading: Icon(
              b.paid ? Icons.check_circle : Icons.schedule,
              color: b.paid ? Colors.green : Colors.orange,
            ),
            title: Text(_tenantTitle(repository, b, l10n)),
            subtitle: Text(
                '${l10n.billFeeSummary(
                  moneyShort(b.rent),
                  moneyShort(b.propertyFee),
                  moneyShort(b.waterFee + b.electricityFee + b.gasFee),
                )}${b.note.isEmpty ? '' : ' · ${b.note}'}'),
            trailing: Text(formatMoney(b.total, currency),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => context.push(
              AppRoutes.bill(b.tenantId, b.year, b.month),
            ),
          ),
      ],
    );
  }

  String _tenantTitle(
      BillRepository repository, Bill bill, AppLocalizations l10n) {
    final Tenant? t = repository.tenantById(bill.tenantId);
    if (t == null) {
      return l10n.commonTenantDeleted;
    }
    return '${t.room} · ${t.name}${bill.paid ? l10n.historyPaidSuffix : ''}';
  }

  String moneyShort(int cents) => moneyToText(cents);
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../../data/repositories/bill_repository.dart';
import '../../../domain/models/bill.dart';
import '../../../domain/models/currency.dart';
import '../../../domain/models/tenant.dart';
import '../../core/currency_scope.dart';
import '../../core/format.dart';

/// 统计：累计实收/应收、近 12 个月趋势、费用构成、租户排名。
class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final BillRepository repository = context.watch<BillRepository>();
    final List<Bill> bills = repository.bills;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
      body: bills.isEmpty
          ? Center(child: Text(l10n.statsEmpty))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: <Widget>[
                _ReceivableSummaryCard(bills: bills),
                const SizedBox(height: 12),
                _MonthlyTrendCard(bills: bills),
                const SizedBox(height: 12),
                _CategoryBreakdownCard(bills: bills),
                const SizedBox(height: 12),
                _TenantRankingCard(repository: repository, bills: bills),
              ],
            ),
    );
  }
}

Card _cardShell({required Widget child}) {
  return Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: child,
    ),
  );
}

Text _cardTitle(String text) =>
    Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

/// 累计应收 / 已收 / 未收 + 收缴率。
class _ReceivableSummaryCard extends StatelessWidget {
  const _ReceivableSummaryCard({required this.bills});

  final List<Bill> bills;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    int receivable = 0;
    int received = 0;
    for (final Bill b in bills) {
      receivable += b.total;
      if (b.paid) {
        received += b.total;
      }
    }
    final int unpaid = receivable - received;
    final double rate = receivable == 0 ? 0 : received / receivable;

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _cardTitle(l10n.statsSummaryTitle),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              _statColumn(l10n.statsReceivable, receivable,
                  Theme.of(context).colorScheme.primary, currency),
              _statColumn(
                  l10n.commonPaid, received, Colors.green.shade600, currency),
              _statColumn(
                  l10n.commonUnpaid, unpaid, Colors.orange.shade700, currency),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 8,
              backgroundColor: Colors.orange.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.statsCollectionRate((rate * 100).toStringAsFixed(1)),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _statColumn(
      String label, int cents, Color color, Currency currency) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(cents, currency),
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// 近 12 个月应收合计柱状图（绿色为已收，橙色为未收，含未录账单的月份为 0）。
class _MonthlyTrendCard extends StatelessWidget {
  const _MonthlyTrendCard({required this.bills});

  final List<Bill> bills;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    final String localeName = Localizations.localeOf(context).toString();
    final DateTime now = DateTime.now();
    // 从 11 个月前到本月，共 12 个 periodKey。
    final List<int> keys = <int>[
      for (int i = 11; i >= 0; i--)
        DateTime(now.year, now.month - i).year * 12 +
            DateTime(now.year, now.month - i).month,
    ];
    final Map<int, int> paidTotals = <int, int>{
      for (final int k in keys) k: 0,
    };
    final Map<int, int> unpaidTotals = <int, int>{
      for (final int k in keys) k: 0,
    };
    for (final Bill b in bills) {
      if (!paidTotals.containsKey(b.periodKey)) {
        continue;
      }
      if (b.paid) {
        paidTotals[b.periodKey] = paidTotals[b.periodKey]! + b.total;
      } else {
        unpaidTotals[b.periodKey] = unpaidTotals[b.periodKey]! + b.total;
      }
    }
    int maxTotal = 0;
    for (final int k in keys) {
      final int sum = paidTotals[k]! + unpaidTotals[k]!;
      if (sum > maxTotal) {
        maxTotal = sum;
      }
    }

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _cardTitle(l10n.statsMonthlyTrendTitle),
              const Spacer(),
              _legendDot(Colors.green.shade500, l10n.commonPaid),
              const SizedBox(width: 10),
              _legendDot(Colors.orange.shade400, l10n.commonUnpaid),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxTotal == 0 ? 100 : maxTotal * 1.15,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int key = value.toInt();
                        final int month = key % 12 == 0 ? 12 : key % 12;
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(shortMonthLabel(month, localeName),
                              style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (BarChartGroupData group, int groupIndex,
                        BarChartRodData rod, int rodIndex) {
                      final int paid = paidTotals[group.x]!;
                      final int unpaid = unpaidTotals[group.x]!;
                      return BarTooltipItem(
                        l10n.statsChartTooltip(
                            formatMoney(paid, currency),
                            formatMoney(unpaid, currency)),
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                barGroups: <BarChartGroupData>[
                  for (int i = 0; i < keys.length; i++)
                    BarChartGroupData(
                      x: keys[i],
                      barRods: <BarChartRodData>[
                        BarChartRodData(
                          toY: (paidTotals[keys[i]]! + unpaidTotals[keys[i]]!)
                              .toDouble(),
                          width: 14,
                          borderRadius: BorderRadius.circular(3),
                          rodStackItems: <BarChartRodStackItem>[
                            BarChartRodStackItem(
                              0,
                              paidTotals[keys[i]]!.toDouble(),
                              Colors.green.shade500,
                            ),
                            BarChartRodStackItem(
                              paidTotals[keys[i]]!.toDouble(),
                              (paidTotals[keys[i]]! + unpaidTotals[keys[i]]!)
                                  .toDouble(),
                              Colors.orange.shade400,
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

/// 费用分类（用于构成饼图与图例）。
enum _FeeCategory {
  rent(Colors.teal),
  propertyFee(Colors.orange),
  waterFee(Colors.blue),
  electricityFee(Colors.amber),
  gasFee(Colors.purple);

  const _FeeCategory(this.color);

  final Color color;
}

/// 费用分类的本地化名称。
String _feeCategoryLabel(AppLocalizations l10n, _FeeCategory category) =>
    switch (category) {
      _FeeCategory.rent => l10n.feeRent,
      _FeeCategory.propertyFee => l10n.feeProperty,
      _FeeCategory.waterFee => l10n.feeWater,
      _FeeCategory.electricityFee => l10n.feeElectricity,
      _FeeCategory.gasFee => l10n.feeGas,
    };

/// 全部账单的费用构成饼图。
class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.bills});

  final List<Bill> bills;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    final Map<_FeeCategory, int> sums = <_FeeCategory, int>{
      for (final _FeeCategory c in _FeeCategory.values) c: 0,
    };
    for (final Bill b in bills) {
      sums[_FeeCategory.rent] = sums[_FeeCategory.rent]! + b.rent;
      sums[_FeeCategory.propertyFee] =
          sums[_FeeCategory.propertyFee]! + b.propertyFee;
      sums[_FeeCategory.waterFee] = sums[_FeeCategory.waterFee]! + b.waterFee;
      sums[_FeeCategory.electricityFee] =
          sums[_FeeCategory.electricityFee]! + b.electricityFee;
      sums[_FeeCategory.gasFee] = sums[_FeeCategory.gasFee]! + b.gasFee;
    }
    final int grand = sums.values.fold<int>(0, (int a, int b) => a + b);
    if (grand == 0) {
      return _cardShell(child: _cardTitle(l10n.statsCategoryEmpty));
    }

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _cardTitle(l10n.statsCategoryTitle),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              SizedBox(
                width: 160,
                height: 160,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 32,
                    sections: <PieChartSectionData>[
                      for (final _FeeCategory c in _FeeCategory.values)
                        if (sums[c]! > 0)
                          PieChartSectionData(
                            value: sums[c]!.toDouble(),
                            color: c.color,
                            radius: 34,
                            title:
                                '${(sums[c]! * 100 / grand).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final _FeeCategory c in _FeeCategory.values)
                      if (sums[c]! > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: c.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(_feeCategoryLabel(l10n, c),
                                  style: const TextStyle(fontSize: 13)),
                              const Spacer(),
                              Text(formatMoney(sums[c]!, currency),
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 各租户累计应收排名（附已收 / 未收）。
class _TenantRankingCard extends StatelessWidget {
  const _TenantRankingCard({required this.repository, required this.bills});

  final BillRepository repository;
  final List<Bill> bills;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Map<String, int> receivable = <String, int>{};
    final Map<String, int> received = <String, int>{};
    for (final Bill b in bills) {
      receivable[b.tenantId] = (receivable[b.tenantId] ?? 0) + b.total;
      if (b.paid) {
        received[b.tenantId] = (received[b.tenantId] ?? 0) + b.total;
      }
    }
    if (receivable.isEmpty) {
      return _cardShell(child: _cardTitle(l10n.statsTenantRankingEmpty));
    }
    final List<MapEntry<String, int>> ranked = receivable.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
          b.value.compareTo(a.value));
    final int max = ranked.first.value;

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _cardTitle(l10n.statsTenantRankingTitle),
          const SizedBox(height: 12),
          for (final MapEntry<String, int> e in ranked)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildRow(context, e, received[e.key] ?? 0, max),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    MapEntry<String, int> entry,
    int received,
    int max,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    final Tenant? tenant = repository.tenantById(entry.key);
    final String label = tenant == null
        ? l10n.commonTenantDeleted
        : '${tenant.room} · ${tenant.name}';
    final int unpaid = entry.value - received;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: Text(label, style: const TextStyle(fontSize: 13))),
            Text(formatMoney(entry.value, currency),
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: <Widget>[
            Text(l10n.commonReceivedAmount(formatMoney(received, currency)),
                style: TextStyle(fontSize: 11, color: Colors.green.shade700)),
            if (unpaid > 0) ...<Widget>[
              const SizedBox(width: 8),
              Text(l10n.commonUnpaidAmount(formatMoney(unpaid, currency)),
                  style:
                      TextStyle(fontSize: 11, color: Colors.orange.shade800)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: max == 0 ? 0 : entry.value / max,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

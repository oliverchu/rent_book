import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../../data/repositories/bill_repository.dart';
import '../../../data/services/app_settings.dart';
import '../../../domain/models/bill.dart';
import '../../../domain/models/currency.dart';
import '../../../domain/models/tenant.dart';
import '../../core/currency_scope.dart';
import '../../core/format.dart';
import '../../router/app_router.dart';

/// 首页：按月查看每位租户的费用并快速录入。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selected = DateTime(now.year, now.month);
  }

  BillRepository get _repo => context.read<BillRepository>();

  bool get _isCurrentMonth {
    final DateTime now = DateTime.now();
    return _selected.year == now.year && _selected.month == now.month;
  }

  Future<void> _openEdit(Tenant tenant) async {
    await context.push(
      AppRoutes.bill(tenant.id, _selected.year, _selected.month),
    );
  }

  Future<void> _quickAddBill() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_repo.tenants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeAddTenantFirst)),
      );
      return;
    }
    final Tenant? picked = await showModalBottomSheet<Tenant>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.homePickTenantTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (final Tenant t in _repo.tenants)
              ListTile(
                leading: CircleAvatar(child: Text(t.name.characters.first)),
                title: Text('${t.room} · ${t.name}'),
                onTap: () => Navigator.of(context).pop(t),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      await _openEdit(picked);
    }
  }

  static const String _systemChoice = 'system';
  static const String _autoChoice = 'auto';

  Future<void> _pickLanguage() async {
    final AppSettings settings = context.read<AppSettings>();
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String current = settings.locale?.languageCode ?? _systemChoice;
    final String? picked = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => SimpleDialog(
        title: Text(l10n.homeLanguage),
        children: <Widget>[
          _choiceTile(
              dialogContext, l10n.languageSystem, _systemChoice, current),
          _choiceTile(dialogContext, 'English', 'en', current),
          _choiceTile(dialogContext, '中文', 'zh', current),
          _choiceTile(dialogContext, '한국어', 'ko', current),
          _choiceTile(dialogContext, '日本語', 'ja', current),
        ],
      ),
    );
    if (picked == null) {
      return;
    }
    settings.setLocale(picked == _systemChoice ? null : Locale(picked));
  }

  Future<void> _pickCurrency() async {
    final AppSettings settings = context.read<AppSettings>();
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String current = settings.currencyOverride?.code ?? _autoChoice;
    final String? picked = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => SimpleDialog(
        title: Text(l10n.homeCurrency),
        children: <Widget>[
          _choiceTile(dialogContext, l10n.currencyAuto, _autoChoice, current),
          for (final Currency c in Currency.values)
            _choiceTile(
                dialogContext, '${c.code}  ${c.symbol}', c.code, current),
        ],
      ),
    );
    if (picked == null) {
      return;
    }
    settings.setCurrency(
        picked == _autoChoice ? null : Currency.fromCode(picked));
  }

  Widget _choiceTile(
      BuildContext dialogContext, String label, String value, String current) {
    return ListTile(
      title: Text(label),
      trailing: value == current ? const Icon(Icons.check) : null,
      onTap: () => Navigator.of(dialogContext).pop(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.statsTitle,
            icon: const Icon(Icons.insights),
            onPressed: () => context.push(AppRoutes.stats),
          ),
          IconButton(
            tooltip: l10n.historyTitle,
            icon: const Icon(Icons.history),
            onPressed: () => context.push(AppRoutes.history),
          ),
          IconButton(
            tooltip: l10n.tenantsTitle,
            icon: const Icon(Icons.people_outline),
            onPressed: () => context.push(AppRoutes.tenants),
          ),
          // 低频入口收进溢出菜单，避免小屏拥挤。
          PopupMenuButton<String>(
            tooltip: l10n.homeMoreTooltip,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'language',
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.homeLanguage),
                ),
              ),
              PopupMenuItem<String>(
                value: 'currency',
                child: ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: Text(l10n.homeCurrency),
                ),
              ),
              PopupMenuItem<String>(
                value: 'change_password',
                child: ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: Text(l10n.changePasswordTitle),
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'language') {
                _pickLanguage();
              } else if (value == 'currency') {
                _pickCurrency();
              } else if (value == 'change_password') {
                context.push(AppRoutes.changePassword);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _quickAddBill,
        icon: const Icon(Icons.receipt_long),
        label: Text(l10n.homeAddBill),
      ),
      body: ListenableBuilder(
        listenable: _repo,
        builder: (BuildContext context, _) {
          final List<Tenant> tenants = _repo.tenants;
          return Column(
            children: <Widget>[
              _buildMonthSwitcher(),
              if (tenants.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.home_work_outlined,
                            size: 72, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(l10n.homeEmptyTenants),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => context.push(AppRoutes.tenants),
                          icon: const Icon(Icons.person_add_alt),
                          label: Text(l10n.homeAddTenant),
                        ),
                      ],
                    ),
                  ),
                )
              else ...<Widget>[
                _buildSummary(),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: tenants.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) =>
                        _buildTenantCard(tenants[index]),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSwitcher() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: SizedBox(
        height: 48,
        child: Stack(
          children: <Widget>[
            // 月份切换组始终居中，不因“回到本月”的出现而被顶偏。
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    tooltip: l10n.homePreviousMonth,
                    onPressed: () => setState(() {
                      _selected =
                          DateTime(_selected.year, _selected.month - 1);
                    }),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  TextButton(
                    onPressed: () => _pickMonth(),
                    child: Text(
                      monthLabel(
                        _selected.year,
                        _selected.month,
                        Localizations.localeOf(context).toString(),
                      ),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.homeNextMonth,
                    onPressed: () => setState(() {
                      _selected =
                          DateTime(_selected.year, _selected.month + 1);
                    }),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            // “回到本月”固定悬浮在最右边。
            if (!_isCurrentMonth)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => setState(() {
                      final DateTime now = DateTime.now();
                      _selected = DateTime(now.year, now.month);
                    }),
                    child: Text(l10n.homeBackToThisMonth),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selected = DateTime(picked.year, picked.month);
      });
    }
  }

  Widget _buildSummary() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    final List<Tenant> tenants = _repo.tenants;
    int recorded = 0;
    int paidCount = 0;
    for (final Tenant t in tenants) {
      final Bill? b = _repo.billFor(t.id, _selected.year, _selected.month);
      if (b != null) {
        recorded++;
        if (b.paid) {
          paidCount++;
        }
      }
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Colors.teal.shade400, Colors.teal.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.homeMonthlyReceivable,
                    style: TextStyle(color: Colors.white.withAlpha(220))),
                Text(
                  '${currency.symbol} ${formatNumber(_repo.totalForMonth(_selected.year, _selected.month), currency)}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            Flexible(
              child: Text(
                l10n.homeCollectionSummary(
                    paidCount, recorded, tenants.length),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withAlpha(230)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int cents) => moneyToText(cents);

  Widget _buildTenantCard(Tenant tenant) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    final Bill? bill =
        _repo.billFor(tenant.id, _selected.year, _selected.month);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openEdit(tenant),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.teal.shade50,
                foregroundColor: Colors.teal,
                child: Text(tenant.name.characters.first),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${tenant.room} · ${tenant.name}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bill == null
                          ? l10n.homeNotRecorded(
                              _fmt(tenant.rent), _fmt(tenant.propertyFee))
                          : l10n.billFeeSummary(
                              _fmt(bill.rent),
                              _fmt(bill.propertyFee),
                              _fmt(bill.waterFee +
                                  bill.electricityFee +
                                  bill.gasFee)),
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    bill == null
                        ? l10n.homePending
                        : '${currency.symbol} ${formatNumber(bill.total, currency)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bill == null
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (bill != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bill.paid
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        bill.paid ? l10n.commonPaid : l10n.commonUnpaid,
                        style: TextStyle(
                          fontSize: 11,
                          color: bill.paid
                              ? Colors.green.shade700
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

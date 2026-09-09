import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// 录入 / 编辑某月账单。固定支出（房租、物业）自动带出且可修改。
class BillEditView extends StatefulWidget {
  const BillEditView({
    super.key,
    required this.tenant,
    required this.year,
    required this.month,
  });

  final Tenant tenant;
  final int year;
  final int month;

  @override
  State<BillEditView> createState() => _BillEditViewState();
}

class _BillEditViewState extends State<BillEditView> {
  late final TextEditingController _rent;
  late final TextEditingController _propertyFee;
  late final TextEditingController _water;
  late final TextEditingController _electricity;
  late final TextEditingController _gas;
  late final TextEditingController _note;

  Bill? _existing;
  bool _paid = false;

  BillRepository get _repo => context.read<BillRepository>();

  @override
  void initState() {
    super.initState();
    // 优先取本月已有账单；否则带上该租户最近一月（不晚于本月）的金额；再退回租户默认固定值。
    final int currentKey = widget.year * 12 + widget.month;
    final Bill? latest =
        _repo.latestBillFor(widget.tenant.id, beforePeriodKey: currentKey);
    _existing = _repo.billFor(
        widget.tenant.id, widget.year, widget.month);
    final Bill seed = _existing ??
        latest?.copyForPeriod(widget.year, widget.month,
            newId: _newId()) ??
        Bill.fromTenant(widget.tenant, widget.year, widget.month,
            id: _newId());

    _rent = TextEditingController(text: moneyToText(seed.rent));
    _propertyFee = TextEditingController(text: moneyToText(seed.propertyFee));
    _water = TextEditingController(text: moneyToText(seed.waterFee));
    _electricity = TextEditingController(text: moneyToText(seed.electricityFee));
    _gas = TextEditingController(text: moneyToText(seed.gasFee));
    _note = TextEditingController(text: _existing?.note ?? '');
    _paid = _existing?.paid ?? false;
  }

  String _newId() => 'b${DateTime.now().microsecondsSinceEpoch}';

  @override
  void dispose() {
    _rent.dispose();
    _propertyFee.dispose();
    _water.dispose();
    _electricity.dispose();
    _gas.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _total =>
      parseMoney(_rent.text) +
      parseMoney(_propertyFee.text) +
      parseMoney(_water.text) +
      parseMoney(_electricity.text) +
      parseMoney(_gas.text);

  Bill _buildBill() {
    final String id = _existing?.id ?? _newId();
    return Bill(
      id: id,
      tenantId: widget.tenant.id,
      year: widget.year,
      month: widget.month,
      rent: parseMoney(_rent.text),
      propertyFee: parseMoney(_propertyFee.text),
      waterFee: parseMoney(_water.text),
      electricityFee: parseMoney(_electricity.text),
      gasFee: parseMoney(_gas.text),
      paid: _paid,
      note: _note.text.trim(),
    );
  }

  static const List<String> _fields = <String>[
    'rent',
    'propertyFee',
    'water',
    'electricity',
    'gas',
  ];

  String _fieldLabel(AppLocalizations l10n, String key) => switch (key) {
        'rent' => l10n.feeRent,
        'propertyFee' => l10n.feeProperty,
        'water' => l10n.feeWater,
        'electricity' => l10n.feeElectricity,
        _ => l10n.feeGas,
      };

  TextEditingController _controllerOf(String key) {
    return switch (key) {
      'rent' => _rent,
      'propertyFee' => _propertyFee,
      'water' => _water,
      'electricity' => _electricity,
      _ => _gas,
    };
  }

  Future<void> _save({required bool thenShare}) async {
    await _repo.saveBill(_buildBill());
    if (!mounted) {
      return;
    }
    if (thenShare) {
      context.pushReplacement(
        AppRoutes.billShare(widget.tenant.id, widget.year, widget.month),
      );
    } else {
      context.pop();
    }
  }

  Future<void> _delete() async {
    final Bill? existing = _existing;
    if (existing == null) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.billEditDelete),
        content: Text(l10n.billEditDeleteMessage),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.deleteBill(existing.id);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tenant.room} '
            '${monthLabel(widget.year, widget.month, Localizations.localeOf(context).toString())}'),
        actions: <Widget>[
          if (_existing != null)
            IconButton(
              tooltip: l10n.billEditDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _save(thenShare: false),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.commonSave),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => _save(thenShare: true),
                  icon: const Icon(Icons.image_outlined),
                  label: Text(l10n.billEditSaveAndShare),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Text(l10n.billEditTotalLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    '${currency.symbol} ${formatNumber(_total, currency)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.billEditPaidSwitch),
            value: _paid,
            onChanged: (bool v) => setState(() => _paid = v),
          ),
          for (final String key in _fields)
            _moneyField(_fieldLabel(l10n, key), _controllerOf(key), l10n),
          TextField(
            controller: _note,
            decoration: InputDecoration(
              labelText: l10n.billEditNoteLabel,
              hintText: l10n.billEditNoteHint,
            ),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.billEditHint,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _moneyField(
      String label, TextEditingController controller, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        onChanged: (_) => setState(() {}),
        onTap: () {
          // 点击金额框时全选原值，直接输入即可覆盖（避免出现 035.6）。
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
        decoration:
            InputDecoration(labelText: l10n.billEditMoneyFieldLabel(label)),
      ),
    );
  }
}

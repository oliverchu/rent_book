import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../../data/repositories/bill_repository.dart';
import '../../../domain/models/bill.dart';
import '../../../domain/models/currency.dart';
import '../../../domain/models/tenant.dart';
import '../../core/currency_scope.dart';
import '../../core/format.dart';

/// 租户管理：新增、编辑（固定房租/物业费）、删除。
class TenantsManageView extends StatelessWidget {
  const TenantsManageView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Tenant> tenants = context.watch<BillRepository>().tenants;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tenantsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context),
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.tenantsAdd),
      ),
      body: tenants.isEmpty
          ? Center(child: Text(l10n.tenantsEmpty))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: tenants.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) =>
                  _buildTile(context, tenants[index]),
            ),
    );
  }

  Widget _buildTile(BuildContext context, Tenant tenant) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Currency currency = CurrencyScope.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade50,
          foregroundColor: Colors.teal,
          child: Text(tenant.name.characters.first),
        ),
        title: Text('${tenant.room} · ${tenant.name}'),
        subtitle: Text(l10n.tenantsFeeSummary(
            formatMoney(tenant.rent, currency),
            formatMoney(tenant.propertyFee, currency))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              tooltip: l10n.commonEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEditDialog(context, tenant: tenant),
            ),
            IconButton(
              tooltip: l10n.commonDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, tenant),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete(BuildContext context, Tenant tenant) async {
    final BillRepository repository = context.read<BillRepository>();
    final int billCount = repository.bills
        .where((Bill b) => b.tenantId == tenant.id)
        .length;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext innerContext) => AlertDialog(
        title: Text(l10n.tenantsDeleteTitle),
        content: Text(billCount > 0
            ? l10n.tenantsDeleteWithBillsMessage(
                tenant.room, tenant.name, billCount)
            : l10n.tenantsDeleteMessage(tenant.room, tenant.name)),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(innerContext, false),
              child: Text(l10n.commonCancel)),
          FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(innerContext, true),
              child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await repository.deleteTenant(tenant.id);
    if (!context.mounted) {
      return;
    }
    _toast(
        context,
        '${l10n.tenantsDeleted(tenant.room, tenant.name)}'
        '${billCount > 0 ? l10n.tenantsDeletedWithBillsSuffix(billCount) : ''}');
  }

  Future<void> _showEditDialog(BuildContext context, {Tenant? tenant}) async {
    final BillRepository repository = context.read<BillRepository>();
    final Tenant? result = await showDialog<Tenant>(
      context: context,
      builder: (BuildContext innerContext) =>
          _TenantDialog(existing: tenant),
    );
    if (result == null || !context.mounted) {
      return;
    }
    await repository.saveTenant(result);
    if (!context.mounted) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    _toast(context, tenant == null
        ? l10n.tenantsAdded(result.room, result.name)
        : l10n.tenantsUpdated(result.room, result.name));
  }
}

/// 新增 / 编辑租户对话框。
///
/// 控制器由本 [State] 持有并在 [dispose] 中释放，
/// 避免对话框退场动画期间出现"use after dispose"。
class _TenantDialog extends StatefulWidget {
  const _TenantDialog({this.existing});

  final Tenant? existing;

  @override
  State<_TenantDialog> createState() => _TenantDialogState();
}

class _TenantDialogState extends State<_TenantDialog> {
  late final TextEditingController _room;
  late final TextEditingController _name;
  late final TextEditingController _rent;
  late final TextEditingController _property;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _room = TextEditingController(text: widget.existing?.room ?? '');
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _rent =
        TextEditingController(text: moneyToText(widget.existing?.rent ?? 0));
    _property = TextEditingController(
        text: moneyToText(widget.existing?.propertyFee ?? 0));
  }

  @override
  void dispose() {
    _room.dispose();
    _name.dispose();
    _rent.dispose();
    _property.dispose();
    super.dispose();
  }

  void _submit() {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return; // 校验失败：输入框下方红字提示，对话框保持打开。
    }
    Navigator.of(context).pop(
      Tenant(
        id: widget.existing?.id ??
            't${DateTime.now().microsecondsSinceEpoch}',
        name: _name.text.trim(),
        room: _room.text.trim(),
        rent: parseMoney(_rent.text),
        propertyFee: parseMoney(_property.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isEditing = widget.existing != null;
    return AlertDialog(
      title: Text(isEditing ? l10n.tenantsEditTitle : l10n.tenantsAdd),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _room,
                autofocus: !isEditing,
                decoration: InputDecoration(labelText: l10n.tenantsRoomLabel),
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? l10n.tenantsRoomRequired
                    : null,
              ),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.tenantsNameLabel),
                validator: (String? v) => (v == null || v.trim().isEmpty)
                    ? l10n.tenantsNameRequired
                    : null,
              ),
              TextFormField(
                controller: _rent,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.tenantsRentLabel),
              ),
              TextFormField(
                controller: _property,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    InputDecoration(labelText: l10n.tenantsPropertyLabel),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.commonSave)),
      ],
    );
  }
}

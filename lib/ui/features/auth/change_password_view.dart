import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../../data/services/password_service.dart';
import '../../core/password_field.dart';

/// 修改启动密码：原密码 + 新密码（两次）。
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _old = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return; // 各输入框下方红字提示
    }
    final PasswordService service = context.read<PasswordService>();
    final bool oldOk = await service.verify(_old.text);
    if (!mounted) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!oldOk) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
            SnackBar(content: Text(l10n.changePasswordOldIncorrect)));
      return;
    }
    if (_old.text == _new.text) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.changePasswordSameAsOld)));
      return;
    }
    await service.setPassword(_new.text);
    if (!mounted) {
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.changePasswordSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: () => _submit(),
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.changePasswordSubmit),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: <Widget>[
            PasswordField(
              controller: _old,
              label: l10n.changePasswordOldLabel,
              validator: (String? v) => (v == null || v.isEmpty)
                  ? l10n.changePasswordOldRequired
                  : null,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _new,
              label: l10n.changePasswordNewLabel(PasswordService.minLength),
              validator: (String? v) => (v == null ||
                      v.length < PasswordService.minLength)
                  ? l10n.passwordMinLengthError(PasswordService.minLength)
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _confirm,
              label: l10n.changePasswordConfirmLabel,
              validator: (String? v) => (v != _new.text)
                  ? l10n.changePasswordMismatch
                  : null,
              textInputAction: TextInputAction.done,
              onSubmitted: () => _submit(),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.changePasswordHint,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

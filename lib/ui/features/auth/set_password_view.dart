import 'package:flutter/material.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../../data/services/password_service.dart';
import '../../core/password_field.dart';

/// 首次使用：设置启动密码（输入两次校验）。
class SetPasswordView extends StatefulWidget {
  const SetPasswordView({
    super.key,
    required this.service,
    this.onCompleted,
  });

  final PasswordService service;

  /// 设置成功后由外层切换到主界面。
  final VoidCallback? onCompleted;

  @override
  State<SetPasswordView> createState() => _SetPasswordViewState();
}

class _SetPasswordViewState extends State<SetPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _first = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    final String value = v ?? '';
    if (value.length < PasswordService.minLength) {
      return AppLocalizations.of(context)
          .passwordMinLengthError(PasswordService.minLength);
    }
    return null;
  }

  Future<void> _submit() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    if (_first.text != _confirm.text) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).passwordMismatch)));
      return;
    }
    // 等待写盘完成再进入主界面，避免用户立即杀进程导致密码未落盘。
    await widget.service.setPassword(_first.text);
    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(Icons.lock_outline,
                      size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(l10n.setPasswordTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(l10n.setPasswordSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  PasswordField(
                    controller: _first,
                    label:
                        l10n.setPasswordFieldLabel(PasswordService.minLength),
                    autofocus: true,
                    validator: _validate,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    controller: _confirm,
                    label: l10n.setPasswordConfirmLabel,
                    validator: _validate,
                    textInputAction: TextInputAction.done,
                    onSubmitted: () => _submit(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52)),
                    onPressed: () => _submit(),
                    icon: const Icon(Icons.check),
                    label: Text(l10n.setPasswordSubmit),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../../data/services/password_service.dart';
import '../../core/password_field.dart';

/// 启动解锁页。
class LockView extends StatefulWidget {
  const LockView({
    super.key,
    required this.service,
    this.onUnlocked,
    this.onForgotPassword,
  });

  final PasswordService service;
  final VoidCallback? onUnlocked;

  /// 点击「忘记密码」时回调（由外层决定重置策略）。
  final VoidCallback? onForgotPassword;

  @override
  State<LockView> createState() => _LockViewState();
}

class _LockViewState extends State<LockView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();

  /// 校验期间置为 true，避免重复提交并展示进度。
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_busy) {
      return;
    }
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    setState(() => _busy = true);
    final bool ok = await widget.service.verify(_password.text);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (!ok) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.lockViewWrongPassword)));
      _password.clear();
      return;
    }
    widget.onUnlocked?.call();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                    Icon(Icons.lock,
                        size: 64, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(l10n.lockViewTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    PasswordField(
                      controller: _password,
                      label: l10n.lockViewPasswordLabel,
                      autofocus: true,
                      validator: (String? v) =>
                          (v == null || v.isEmpty)
                              ? l10n.lockViewPasswordRequired
                              : null,
                      onSubmitted: _unlock,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52)),
                      onPressed: _busy ? null : _unlock,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_open_outlined),
                      label:
                          Text(_busy ? l10n.lockViewVerifying : l10n.lockViewUnlock),
                    ),
                    if (widget.onForgotPassword != null) ...<Widget>[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: widget.onForgotPassword,
                        child: Text(l10n.lockViewForgotPassword),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../../data/repositories/bill_repository.dart';
import '../../../data/services/password_service.dart';
import '../../router/app_router.dart';
import '../home/home_view.dart';
import 'lock_view.dart';
import 'set_password_view.dart';

/// 启动门禁：未设置过密码 → 先设置；已设置 → 每次启动解锁。
///
/// 切到后台再回来会重新上锁，避免手机借人时账单被翻看。
class PasswordGate extends StatefulWidget {
  const PasswordGate({super.key});

  @override
  State<PasswordGate> createState() => _PasswordGateState();
}

class _PasswordGateState extends State<PasswordGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 切后台即视为离开，回到前台需要重新解锁。
    if (state == AppLifecycleState.paused && _unlocked) {
      setState(() => _unlocked = false);
      // 同时回到根路由，避免其它页面仍盖在解锁页之上。
      if (mounted) {
        GoRouter.of(context).go(AppRoutes.home);
      }
    }
  }

  /// 忘记密码：确认后清空密码与全部数据，从设置新密码重新开始。
  Future<void> _resetAll() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.lockViewForgotPassword),
        content: Text(l10n.passwordGateResetMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.passwordGateResetConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final BillRepository repository = context.read<BillRepository>();
    final PasswordService service = context.read<PasswordService>();
    await repository.clearAll();
    await service.clear();
    if (mounted) {
      setState(() {}); // 回到「设置密码」分支。
    }
  }

  @override
  Widget build(BuildContext context) {
    final PasswordService service = context.read<PasswordService>();
    if (!service.hasPassword) {
      return SetPasswordView(
        service: service,
        onCompleted: () => setState(() => _unlocked = true),
      );
    }
    if (!_unlocked) {
      return LockView(
        service: service,
        onUnlocked: () => setState(() => _unlocked = true),
        onForgotPassword: _resetAll,
      );
    }
    return const HomePage();
  }
}

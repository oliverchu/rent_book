import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/l10n/app_localizations.dart';

import '../../data/repositories/bill_repository.dart';
import '../../domain/models/bill.dart';
import '../../domain/models/tenant.dart';
import '../features/auth/change_password_view.dart';
import '../features/auth/password_gate.dart';
import '../features/bill_edit/bill_edit_view.dart';
import '../features/bill_share/bill_share_view.dart';
import '../features/home/history_view.dart';
import '../features/stats/stats_view.dart';
import '../features/tenants/tenants_manage_view.dart';

/// 路由路径常量，避免各处硬编码字符串。
abstract final class AppRoutes {
  static const String home = '/';
  static const String stats = '/stats';
  static const String history = '/history';
  static const String tenants = '/tenants';
  static const String changePassword = '/change-password';

  static const String _billPattern = '/bill/:tenantId/:year/:month';

  static String bill(String tenantId, int year, int month) =>
      '/bill/$tenantId/$year/$month';

  static String billShare(String tenantId, int year, int month) =>
      '/bill/$tenantId/$year/$month/share';

  /// 供 [GoRoute] 注册使用。
  static String get billPattern => _billPattern;

  static String get billSharePattern => '$_billPattern/share';
}

/// 每次调用都返回新的 [GoRouter]，保证测试之间路由状态互不干扰。
GoRouter createAppRouter() {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const PasswordGate(),
      ),
      GoRoute(
        path: AppRoutes.stats,
        builder: (_, _) => const StatsView(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (_, _) => const HistoryView(),
      ),
      GoRoute(
        path: AppRoutes.tenants,
        builder: (_, _) => const TenantsManageView(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (_, _) => const ChangePasswordView(),
      ),
      GoRoute(
        path: AppRoutes.billPattern,
        builder: (BuildContext context, GoRouterState state) {
          final Tenant? tenant = context
              .read<BillRepository>()
              .tenantById(state.pathParameters['tenantId']!);
          if (tenant == null) {
            return const _MissingDataView();
          }
          return BillEditView(
            tenant: tenant,
            year: int.parse(state.pathParameters['year']!),
            month: int.parse(state.pathParameters['month']!),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.billSharePattern,
        builder: (BuildContext context, GoRouterState state) {
          final BillRepository repository = context.read<BillRepository>();
          final String tenantId = state.pathParameters['tenantId']!;
          final int year = int.parse(state.pathParameters['year']!);
          final int month = int.parse(state.pathParameters['month']!);
          final Tenant? tenant = repository.tenantById(tenantId);
          final Bill? bill = repository.billFor(tenantId, year, month);
          if (tenant == null || bill == null) {
            return const _MissingDataView();
          }
          return BillShareView(bill: bill, tenant: tenant);
        },
      ),
    ],
  );
}

/// 路径参数指向的数据已被删除时的兜底页。
class _MissingDataView extends StatelessWidget {
  const _MissingDataView();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.errorDataNotFound)),
      body: Center(child: Text(l10n.errorTenantOrBillNotFound)),
    );
  }
}

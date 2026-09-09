import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rent_book/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/legacy_prefs_migration.dart';
import 'data/datasources/sqlite_bill_store.dart';
import 'data/datasources/sqflite_platform_init.dart';
import 'data/repositories/bill_repository.dart';
import 'data/services/app_settings.dart';
import 'data/services/password_service.dart';
import 'domain/models/tenant.dart';
import 'ui/core/currency_scope.dart';
import 'ui/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 桌面端（Windows/Linux）需切换到 FFI 实现后才能打开数据库。
  initSqfliteForCurrentPlatform();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // 数据落到 SQLite；首次升级时把旧版 SharedPreferences 里的 JSON 迁过来。
  final SqliteBillStore store = SqliteBillStore();
  await store.open();
  await migrateLegacyPrefs(prefs: prefs, store: store);

  final BillRepository repository = BillRepository(store: store);
  await repository.load();
  await _seedDemoIfFirstRun(prefs, repository);

  runApp(RentBookApp(
    repository: repository,
    passwordService: PasswordService(prefs),
    settings: AppSettings(prefs: prefs),
  ));
}

/// 首次安装放一个示例租户，方便直接体验；
/// 用持久化标记保证用户删光租户后不会再次自动出现。
Future<void> _seedDemoIfFirstRun(
  SharedPreferences prefs,
  BillRepository repository,
) async {
  const String seededKey = 'rent_book.seeded';
  if (prefs.getBool(seededKey) ?? false) {
    return;
  }
  await prefs.setBool(seededKey, true);
  if (repository.tenants.isEmpty) {
    await repository.saveTenant(
      const Tenant(
        id: 't-demo-101',
        name: '张三',
        room: '101',
        rent: 150000,
        propertyFee: 20000,
      ),
    );
  }
}

class RentBookApp extends StatefulWidget {
  const RentBookApp({
    super.key,
    required this.repository,
    required this.passwordService,
    this.settings,
  });

  final BillRepository repository;
  final PasswordService passwordService;

  /// 语言/货币设置；测试可省略，省略时使用不落盘的默认值。
  final AppSettings? settings;

  @override
  State<RentBookApp> createState() => _RentBookAppState();
}

class _RentBookAppState extends State<RentBookApp> {
  late final GoRouter _router = createAppRouter();
  late final AppSettings _settings = widget.settings ?? AppSettings();

  @override
  void dispose() {
    if (widget.settings == null) {
      _settings.dispose();
    }
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BillRepository>.value(value: widget.repository),
        Provider<PasswordService>.value(value: widget.passwordService),
        ChangeNotifierProvider<AppSettings>.value(value: _settings),
      ],
      child: Consumer<AppSettings>(
        builder: (BuildContext context, AppSettings settings, _) {
          return MaterialApp.router(
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
            // 语言为 null 时跟随系统；系统语言不在支持列表时回退到第一个（英语）。
            locale: settings.locale,
            supportedLocales: const <Locale>[
              Locale('en'),
              Locale('zh'),
              Locale('ko'),
              Locale('ja'),
            ],
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (BuildContext context, Widget? child) => CurrencyScope(
              currency:
                  settings.currencyFor(Localizations.localeOf(context)),
              child: child ?? const SizedBox.shrink(),
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

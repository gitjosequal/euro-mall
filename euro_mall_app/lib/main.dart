import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_environment.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/app_locale.dart';
import 'core/navigation/app_shell.dart';
import 'core/providers/app_repository_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/otp_page.dart';
import 'features/auth/phone_login_page.dart';
import 'features/auth/register_page.dart';
import 'features/branches/branches_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/offers/offers_page.dart';
import 'features/settings/cms_markdown_page.dart';
import 'features/settings/contact_page.dart';
import 'features/settings/faqs_page.dart';
import 'features/settings/my_profile_page.dart';
import 'features/settings/notification_settings_page.dart';
import 'features/settings/points_schema_page.dart';
import 'features/settings/settings_hub_page.dart';
import 'features/settings/settings_order_history_page.dart';
import 'features/vouchers/voucher_detail_page.dart';
import 'features/vouchers/vouchers_page.dart';
import 'features/wallet/points_history_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/splash/splash_page.dart';

const _prefLocaleKey = 'app_locale';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    debugPrint('[Euro Mall] API base: ${AppEnvironment.apiBaseUrl}');
  }

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_prefLocaleKey);
  final initialLocale = (saved == 'ar' || saved == 'en')
      ? Locale(saved!)
      : AppLocale.fromPlatform();

  runApp(EuroMallApp(prefs: prefs, initialLocale: initialLocale));
}

class AppState extends ChangeNotifier {
  AppState({
    required SharedPreferences prefs,
    required Locale initialLocale,
  })  : _prefs = prefs,
        _locale = initialLocale;

  final SharedPreferences _prefs;
  Locale _locale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    final code = locale.languageCode;
    if (!AppLocale.supportedCodes.contains(code)) return;
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    unawaited(_prefs.setString(_prefLocaleKey, code));
  }

  void toggleLocale() {
    setLocale(
      _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en'),
    );
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}

class EuroMallApp extends StatefulWidget {
  const EuroMallApp({
    super.key,
    required this.prefs,
    required this.initialLocale,
  });

  final SharedPreferences prefs;
  final Locale initialLocale;

  @override
  State<EuroMallApp> createState() => _EuroMallAppState();
}

class _EuroMallAppState extends State<EuroMallApp> {
  late final AppState _appState;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appState = AppState(
      prefs: widget.prefs,
      initialLocale: widget.initialLocale,
    );
    _router = _buildRouter();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _appState,
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/auth/phone',
          name: 'phone',
          builder: (context, state) => const PhoneLoginPage(),
        ),
        GoRoute(
          path: '/auth/otp',
          name: 'otp',
          builder: (context, state) => const OtpPage(),
        ),
        GoRoute(
          path: '/auth/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/vouchers/:id',
          name: 'voucher',
          builder: (context, state) =>
              VoucherDetailPage(voucherId: state.pathParameters['id'] ?? ''),
        ),
        GoRoute(
          path: '/offers',
          name: 'offers',
          builder: (context, state) => const OffersPage(),
        ),
        GoRoute(
          path: '/settings/my-profile',
          name: 'settings_my_profile',
          builder: (context, state) => const MyProfilePage(),
        ),
        GoRoute(
          path: '/settings/terms',
          name: 'settings_terms',
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return CmsMarkdownPage(
              slug: 'terms',
              title: l10n.tr('settings_terms'),
            );
          },
        ),
        GoRoute(
          path: '/settings/privacy',
          name: 'settings_privacy',
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return CmsMarkdownPage(
              slug: 'privacy',
              title: l10n.tr('settings_privacy'),
            );
          },
        ),
        GoRoute(
          path: '/settings/orders',
          name: 'settings_orders',
          builder: (context, state) => const SettingsOrderHistoryPage(),
        ),
        GoRoute(
          path: '/settings/points-schema',
          name: 'settings_points_schema',
          builder: (context, state) => const PointsSchemaPage(),
        ),
        GoRoute(
          path: '/settings/notifications',
          name: 'settings_notifications',
          builder: (context, state) => const NotificationSettingsPage(),
        ),
        GoRoute(
          path: '/settings/about',
          name: 'settings_about',
          builder: (context, state) {
            final l10n = AppLocalizations.of(context);
            return CmsMarkdownPage(
              slug: 'about',
              title: l10n.tr('settings_about'),
            );
          },
        ),
        GoRoute(
          path: '/settings/contact',
          name: 'settings_contact',
          builder: (context, state) => const ContactPage(),
        ),
        GoRoute(
          path: '/settings/faqs',
          name: 'settings_faqs',
          builder: (context, state) => const FaqsPage(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (context, state) => const PointsHistoryPage(),
            ),
            GoRoute(
              path: '/vouchers',
              name: 'vouchers',
              builder: (context, state) => const VouchersPage(),
            ),
            GoRoute(
              path: '/branches',
              name: 'branches',
              builder: (context, state) => const BranchesPage(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const SettingsHubPage(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppRepositoryProviders(
      prefs: widget.prefs,
      child: AppStateScope(
        notifier: _appState,
        child: AnimatedBuilder(
          animation: _appState,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'Euro Mall Loyalty',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(_appState.locale),
              locale: _appState.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}

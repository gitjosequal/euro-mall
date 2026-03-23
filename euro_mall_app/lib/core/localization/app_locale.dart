import 'package:flutter/material.dart';

/// Maps device locale to app-supported [Locale]: Arabic → `ar`, everything else → `en`.
abstract final class AppLocale {
  static const supportedCodes = {'en', 'ar'};

  /// Uses [PlatformDispatcher.locale] (device / system language).
  static Locale fromPlatform([Locale? platformLocale]) {
    final loc = platformLocale ??
        WidgetsBinding.instance.platformDispatcher.locale;
    final code = loc.languageCode.toLowerCase();
    if (code == 'ar') {
      return const Locale('ar');
    }
    return const Locale('en');
  }

  static bool isArabic(Locale locale) => locale.languageCode == 'ar';
}

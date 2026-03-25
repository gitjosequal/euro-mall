import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:euro_mall_app/core/localization/app_localizations.dart';
import 'package:euro_mall_app/features/splash/splash_page.dart';

/// Fast VM/widget smoke (no Firebase / FCM). Run: `flutter test test/euro_mall_boot_test.dart`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SplashPage builds inside localized MaterialApp', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: SplashPage(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(SplashPage), findsOneWidget);
  });
}

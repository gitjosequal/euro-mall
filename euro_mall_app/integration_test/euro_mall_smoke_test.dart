import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:euro_mall_app/main.dart' as app;

/// End-to-end smoke: app boots and builds [MaterialApp].
///
/// Run on a device or simulator:
///   cd euro_mall_app && flutter test integration_test/euro_mall_smoke_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Euro Mall app launches', (WidgetTester tester) async {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // Firebase may be absent in some CI/local setups; app still tests UI shell.
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await tester.pumpWidget(
      app.EuroMallApp(
        prefs: prefs,
        initialLocale: const Locale('en'),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsWidgets);

    // Splash → allow route transition without hanging on timers in CI.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}

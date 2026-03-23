import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:euro_mall_app/main.dart';

void main() {
  testWidgets('App boots: splash shows logo and loading', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      EuroMallApp(prefs: prefs, initialLocale: const Locale('en')),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('App boots in Arabic locale', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      EuroMallApp(prefs: prefs, initialLocale: const Locale('ar')),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

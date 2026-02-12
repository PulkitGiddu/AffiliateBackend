// Basic Flutter widget test for SnatchMart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snatchmart_flutter/main.dart';

void main() {
  testWidgets('App pumps without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SnatchMartApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    // App should show MaterialApp (login or loading)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

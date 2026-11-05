
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/main.dart';

void main() {
  testWidgets('Main navigation works correctly', (tester) async {
    // Launch the application.
    await tester.pumpWidget(const MobileCompanionApp());

    // Verify that Gateway is the initial screen.
    expect(find.text('Gateway'), findsWidgets);

    // Navigate to the Dashboard screen.
    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);

    // Navigate to the Alerts screen.
    await tester.tap(find.byIcon(Icons.warning_amber_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Alerts'), findsWidgets);
  });
}

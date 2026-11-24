
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


  testWidgets('Back navigation returns to previous tab', (tester) async {
    // Launch the application.
    await tester.pumpWidget(const MobileCompanionApp());

    // Navigate from Gateway to Dashboard.
    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    // Navigate from Dashboard to Alerts.
    await tester.tap(find.byIcon(Icons.warning_amber_outlined));
    await tester.pumpAndSettle();

    // Verify that Alerts is selected.
    expect(find.text('Alerts'), findsWidgets);

    // Simulate the Android Back button.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Verify that navigation returns to Dashboard.
    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.selectedIndex, 1);
  });

}

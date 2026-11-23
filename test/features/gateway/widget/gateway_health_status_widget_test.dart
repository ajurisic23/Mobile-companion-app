
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_companion_app/features/gateway/services/gateway_health_service.dart';
import 'package:mobile_companion_app/features/gateway/widgets/gateway_health_status_widget.dart';

void main() {
  Widget buildTestWidget({
    GatewayHealthStatus? status,
    bool isChecking = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: GatewayHealthStatusWidget(
          status: status,
          isChecking: isChecking,
        ),
      ),
    );
  }

  testWidgets('Shows available status', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(status: GatewayHealthStatus.available),
    );

    expect(find.text('Gateway available'), findsOneWidget);
  });

  testWidgets('Shows unavailable status', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(status: GatewayHealthStatus.unavailable),
    );

    expect(find.text('Gateway unavailable'), findsOneWidget);
  });

  testWidgets('Shows timeout status', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(status: GatewayHealthStatus.timeout),
    );

    expect(find.text('Connection timed out'), findsOneWidget);
  });

  testWidgets('Shows network error status', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(status: GatewayHealthStatus.networkError),
    );

    expect(find.text('Network error'), findsOneWidget);
  });

  testWidgets('Shows checking status', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(isChecking: true),
    );

    expect(find.text('Checking gateway...'), findsOneWidget);
  });

  testWidgets('Shows nothing before checking', (tester) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.byType(SizedBox), findsWidgets);
    expect(find.text('Gateway available'), findsNothing);
    expect(find.text('Gateway unavailable'), findsNothing);
    expect(find.text('Checking gateway...'), findsNothing);
  });
}

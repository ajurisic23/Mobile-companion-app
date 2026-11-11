import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/models/connection_failure.dart';
import 'package:mobile_companion_app/features/gateway/screens/connection_screen.dart';
import 'package:mobile_companion_app/features/gateway/validators/gateway_validators.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Finder _hostField() => find.byType(TextFormField).at(0);
Finder _portField() => find.byType(TextFormField).at(1);

void main() {
  testWidgets('empty address is not sent and a warning is shown',
          (tester) async {
        var calls = 0;
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async => calls++,
        )));

        await tester.tap(find.text('Connect'));
        await tester.pumpAndSettle();

        expect(calls, 0);
        expect(find.text(validateGatewayHost('')!), findsOneWidget);
      });

  testWidgets('invalid address is not sent and a warning is shown',
          (tester) async {
        var calls = 0;
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async => calls++,
        )));

        await tester.enterText(_hostField(), '192.168.0.300');
        await tester.tap(find.text('Connect'));
        await tester.pumpAndSettle();

        expect(calls, 0);
        expect(find.text(validateGatewayHost('192.168.0.300')!), findsOneWidget);
      });

  testWidgets('invalid port is checked before sending', (tester) async {
    var calls = 0;
    await tester.pumpWidget(_wrap(ConnectionScreen(
      onConnect: (host, port) async => calls++,
    )));

    await tester.enterText(_hostField(), '192.168.0.100');
    await tester.enterText(_portField(), '99999');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(calls, 0);
    expect(find.text(validateGatewayPort('99999')!), findsOneWidget);
  });

  testWidgets('port is optional and values are trimmed', (tester) async {
    String? sentHost;
    String? sentPort;
    await tester.pumpWidget(_wrap(ConnectionScreen(
      onConnect: (host, port) async {
        sentHost = host;
        sentPort = port;
      },
    )));

    await tester.enterText(_hostField(), ' 192.168.0.100 ');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(sentHost, '192.168.0.100');
    expect(sentPort, '');
  });

  testWidgets('shows a loading indicator while connecting', (tester) async {
    final completer = Completer<void>();
    await tester.pumpWidget(_wrap(ConnectionScreen(
      onConnect: (host, port) => completer.future,
    )));

    await tester.enterText(_hostField(), '192.168.0.100');
    await tester.tap(find.text('Connect'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows a readable message when connecting fails',
          (tester) async {
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async =>
          throw const ConnectionFailure(ConnectionFailureType.timeout),
        )));

        await tester.enterText(_hostField(), '192.168.0.100');
        await tester.tap(find.text('Connect'));
        await tester.pumpAndSettle();

        const expected = ConnectionFailure(ConnectionFailureType.timeout);
        expect(find.text(expected.message), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
      });

  testWidgets('shows a readable message for unexpected errors',
          (tester) async {
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async => throw Exception('boom'),
        )));

        await tester.enterText(_hostField(), '192.168.0.100');
        await tester.tap(find.text('Connect'));
        await tester.pumpAndSettle();

        const expected = ConnectionFailure(ConnectionFailureType.unknown);
        expect(find.text(expected.message), findsOneWidget);
      });

  testWidgets('error disappears when the user edits the input',
          (tester) async {
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async =>
          throw const ConnectionFailure(ConnectionFailureType.timeout),
        )));

        await tester.enterText(_hostField(), '192.168.0.100');
        await tester.tap(find.text('Connect'));
        await tester.pumpAndSettle();

        const expected = ConnectionFailure(ConnectionFailureType.timeout);
        expect(find.text(expected.message), findsOneWidget);

        await tester.enterText(_hostField(), '192.168.0.101');
        await tester.pump();

        expect(find.text(expected.message), findsNothing);
        expect(find.text('Connect'), findsOneWidget);
      });

  testWidgets('user can try again after an error', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(_wrap(ConnectionScreen(
      onConnect: (host, port) async {
        attempts++;
        if (attempts == 1) {
          throw const ConnectionFailure(ConnectionFailureType.timeout);
        }
      },
    )));

    await tester.enterText(_hostField(), '192.168.0.100');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    const failure = ConnectionFailure(ConnectionFailureType.timeout);
    expect(find.text(failure.message), findsNothing);
    expect(find.text('Gateway available'), findsOneWidget);
  });

  testWidgets('shows that the gateway is available after connecting',
          (tester) async {
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async {},
        )));

        await tester.enterText(_hostField(), '192.168.0.100');
        await tester.tap(find.text('Connect'));
        await tester.pumpAndSettle();

        expect(find.text('Gateway available'), findsOneWidget);

        await tester.enterText(_hostField(), '192.168.0.101');
        await tester.pump();

        expect(find.text('Gateway available'), findsNothing);
      });

  testWidgets('simulated data does not claim the gateway is available',
          (tester) async {
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async {},
          onUseSimulated: () async {},
        )));

        await tester.tap(find.text('Simulated data'));
        await tester.pumpAndSettle();

        expect(find.text('Gateway available'), findsNothing);
      });
}
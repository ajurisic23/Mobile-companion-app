import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/models/connection_failure.dart';
import 'package:mobile_companion_app/features/gateway/screens/connection_screen.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';
import 'package:mobile_companion_app/features/gateway/validators/gateway_validators.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Finder _hostField() => find.byType(TextFormField).at(0);
Finder _portField() => find.byType(TextFormField).at(1);

const _first = GatewayInfo(
  name: 'Address 1',
  host: '192.168.0.100',
  port: 10000,
);

const _second = GatewayInfo(
  name: 'Address 2',
  host: '192.168.0.101',
  port: 8080,
);

String _textOf(WidgetTester tester, Finder field) =>
    tester.widget<TextFormField>(field).controller!.text;

void _useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('shows the saved gateways', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_wrap(ConnectionScreen(
      onConnect: (host, port) async {},
      savedGateways: const [_first, _second],
    )));

    expect(find.text('Saved gateways'), findsOneWidget);
    expect(find.text('Address 1'), findsOneWidget);
    expect(find.text('192.168.0.100:10000'), findsOneWidget);
    expect(find.text('Address 2'), findsOneWidget);
    expect(find.text('192.168.0.101:8080'), findsOneWidget);
  });

  testWidgets('hides the saved gateways section when there are none',
          (tester) async {
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async {},
        )));

        expect(find.text('Saved gateways'), findsNothing);
      });

  testWidgets('selecting a saved gateway fills the form and connects',
          (tester) async {
        _useTallScreen(tester);
        GatewayInfo? connected;
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async {},
          onConnectSaved: (gateway) async => connected = gateway,
          savedGateways: const [_first, _second],
        )));

        await tester.tap(find.text('Address 2'));
        await tester.pumpAndSettle();

        expect(connected, _second);
        expect(_textOf(tester, _hostField()), '192.168.0.101');
        expect(_textOf(tester, _portField()), '8080');
        expect(find.text('Gateway available'), findsOneWidget);
      });

  testWidgets('selecting a saved gateway does nothing without a handler',
          (tester) async {
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async {},
          savedGateways: const [_first],
        )));

        await tester.tap(find.text('Address 1'));
        await tester.pumpAndSettle();

        expect(_textOf(tester, _hostField()), isEmpty);
        expect(_textOf(tester, _portField()), isEmpty);
      });

  testWidgets('keeps the form filled and shows an error when a saved gateway fails',
          (tester) async {
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async {},
          onConnectSaved: (gateway) async =>
          throw const ConnectionFailure(ConnectionFailureType.timeout),
          savedGateways: const [_first],
        )));

        await tester.tap(find.text('Address 1'));
        await tester.pumpAndSettle();

        const expected = ConnectionFailure(ConnectionFailureType.timeout);
        expect(find.text(expected.message), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        expect(_textOf(tester, _hostField()), '192.168.0.100');
        expect(_textOf(tester, _portField()), '10000');
      });

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

  testWidgets('shows the address once when the name is the address',
          (tester) async {
        await tester.pumpWidget(_wrap(ConnectionScreen(
          onConnect: (host, port) async {},
          savedGateways: const [
            GatewayInfo(
              name: '192.168.0.100:10000',
              host: '192.168.0.100',
              port: 10000,
            ),
          ],
        )));

        expect(find.text('192.168.0.100:10000'), findsOneWidget);
      });
}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/models/can_port.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';
import 'package:mobile_companion_app/features/gateway/services/can_ports_service.dart';
import 'package:mobile_companion_app/features/gateway/widgets/can_port_selector.dart';

const _gateway = GatewayInfo(
  name: 'Address 1',
  host: '192.168.0.100',
  port: 10000,
);

const _otherGateway = GatewayInfo(
  name: 'Address 2',
  host: '192.168.0.101',
  port: 8080,
);

const _can0 = CanPort(name: 'can0', halName: 'CAN1', enabled: true);
const _can1 = CanPort(name: 'can1', halName: 'CAN2', enabled: true);

class _FakeCanPortsService extends CanPortsService {
  _FakeCanPortsService(this.handler);

  final Future<List<CanPort>> Function(String host, int port) handler;
  final List<String> calls = [];

  @override
  Future<List<CanPort>> fetchPorts({
    required String host,
    required int port,
  }) {
    calls.add('$host:$port');
    return handler(host, port);
  }
}

Widget _wrap({
  required GatewayInfo? gateway,
  required CanPortsService service,
  CanPort? selectedPort,
  ValueChanged<CanPort>? onSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: CanPortSelector(
        gateway: gateway,
        selectedPort: selectedPort,
        onSelected: onSelected ?? (port) {},
        service: service,
      ),
    ),
  );
}

void main() {
  testWidgets('asks the user to connect when there is no gateway',
          (tester) async {
        final service = _FakeCanPortsService((host, port) async => [_can0]);

        await tester.pumpWidget(_wrap(gateway: null, service: service));

        expect(find.text('Connect to a gateway to see its CAN ports.'),
            findsOneWidget);
        expect(service.calls, isEmpty);
      });

  testWidgets('shows a loading indicator while the ports are loading',
          (tester) async {
        final completer = Completer<List<CanPort>>();
        final service = _FakeCanPortsService((host, port) => completer.future);

        await tester.pumpWidget(_wrap(gateway: _gateway, service: service));

        expect(find.text('Loading CAN ports...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        completer.complete([_can0, _can1]);
        await tester.pumpAndSettle();

        expect(find.text('Loading CAN ports...'), findsNothing);
      });

  testWidgets('requests the ports of the gateway', (tester) async {
    final service = _FakeCanPortsService((host, port) async => [_can0]);

    await tester.pumpWidget(_wrap(gateway: _gateway, service: service));
    await tester.pumpAndSettle();

    expect(service.calls, ['192.168.0.100:10000']);
  });

  testWidgets('shows the number of ports and a prompt to select one',
          (tester) async {
        final service = _FakeCanPortsService((host, port) async => [_can0, _can1]);

        await tester.pumpWidget(_wrap(gateway: _gateway, service: service));
        await tester.pumpAndSettle();

        expect(find.text('CAN port'), findsOneWidget);
        expect(find.text('2 ports'), findsOneWidget);
        expect(find.text('Select a CAN port'), findsOneWidget);
      });

  testWidgets('selecting a port reports it', (tester) async {
    CanPort? selected;
    final service = _FakeCanPortsService((host, port) async => [_can0, _can1]);

    await tester.pumpWidget(_wrap(
      gateway: _gateway,
      service: service,
      onSelected: (port) => selected = port,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<CanPort>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('can1 (CAN2)').last);
    await tester.pumpAndSettle();

    expect(selected, _can1);
  });

  testWidgets('shows the selected port', (tester) async {
    final service = _FakeCanPortsService((host, port) async => [_can0, _can1]);

    await tester.pumpWidget(_wrap(
      gateway: _gateway,
      service: service,
      selectedPort: _can1,
    ));
    await tester.pumpAndSettle();

    expect(find.text('can1 (CAN2)'), findsWidgets);
    expect(find.text('Select a CAN port'), findsNothing);
  });

  testWidgets('a disabled port is shown but cannot be selected',
          (tester) async {
        CanPort? selected;
        const disabled = CanPort(name: 'can1', halName: 'CAN2', enabled: false);
        final service =
        _FakeCanPortsService((host, port) async => [_can0, disabled]);

        await tester.pumpWidget(_wrap(
          gateway: _gateway,
          service: service,
          onSelected: (port) => selected = port,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownButton<CanPort>));
        await tester.pumpAndSettle();
        expect(find.text('can1 (CAN2) (disabled)'), findsOneWidget);

        await tester.tap(find.text('can1 (CAN2) (disabled)'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(selected, isNull);
      });

  testWidgets('shows a message when the gateway has no ports',
          (tester) async {
        final service = _FakeCanPortsService((host, port) async => []);

        await tester.pumpWidget(_wrap(gateway: _gateway, service: service));
        await tester.pumpAndSettle();

        expect(find.text('This gateway has no CAN ports available.'),
            findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
      });

  testWidgets('shows the failure message and can try again', (tester) async {
    var attempts = 0;
    final service = _FakeCanPortsService((host, port) async {
      attempts++;
      if (attempts == 1) {
        throw const CanPortsException(CanPortsFailureType.timeout);
      }
      return [_can0];
    });

    await tester.pumpWidget(_wrap(gateway: _gateway, service: service));
    await tester.pumpAndSettle();

    const failure = CanPortsException(CanPortsFailureType.timeout);
    expect(find.text(failure.message), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text(failure.message), findsNothing);
    expect(find.text('1 port'), findsOneWidget);
  });

  testWidgets('shows a readable message for unexpected errors',
          (tester) async {
        final service = _FakeCanPortsService((host, port) async => throw 'boom');

        await tester.pumpWidget(_wrap(gateway: _gateway, service: service));
        await tester.pumpAndSettle();

        expect(find.text('Could not load the CAN ports.'), findsOneWidget);
      });

  testWidgets('loads the ports again when the gateway changes',
          (tester) async {
        final service = _FakeCanPortsService((host, port) async => [_can0]);

        await tester.pumpWidget(_wrap(gateway: _gateway, service: service));
        await tester.pumpAndSettle();
        await tester.pumpWidget(_wrap(gateway: _otherGateway, service: service));
        await tester.pumpAndSettle();

        expect(service.calls, ['192.168.0.100:10000', '192.168.0.101:8080']);
      });

  testWidgets('ignores a late response of the previous gateway',
          (tester) async {
        final first = Completer<List<CanPort>>();
        final second = Completer<List<CanPort>>();
        final service = _FakeCanPortsService(
              (host, port) => host == '192.168.0.100' ? first.future : second.future,
        );

        await tester.pumpWidget(_wrap(gateway: _gateway, service: service));
        await tester.pumpWidget(_wrap(gateway: _otherGateway, service: service));

        second.complete([_can0]);
        await tester.pumpAndSettle();
        first.complete([_can0, _can1]);
        await tester.pumpAndSettle();

        expect(find.text('1 port'), findsOneWidget);
        expect(find.text('2 ports'), findsNothing);
      });

  testWidgets('clears the ports when the gateway is removed', (tester) async {
    final service = _FakeCanPortsService((host, port) async => [_can0]);

    await tester.pumpWidget(_wrap(gateway: _gateway, service: service));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_wrap(gateway: null, service: service));
    await tester.pumpAndSettle();

    expect(find.text('1 port'), findsNothing);
    expect(find.text('Connect to a gateway to see its CAN ports.'),
        findsOneWidget);
  });
}
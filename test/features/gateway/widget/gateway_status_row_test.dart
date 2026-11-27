import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_health_service.dart';
import 'package:mobile_companion_app/features/gateway/widgets/gateway_status_row.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

class _FakeHealthService extends GatewayHealthService {
  _FakeHealthService(this.handler);

  final Future<GatewayHealthStatus> Function(String address, int port) handler;
  final List<String> calls = [];

  bool isClosed = false;

  @override
  Future<GatewayHealthStatus> checkHealth({
    required String address,
    required int port,
  }) {
    calls.add('$address:$port');
    return handler(address, port);
  }

  @override
  void close() {
    isClosed = true;
    super.close();
  }
}

class _TrackingClient extends MockClient {
  _TrackingClient()
    : super((request) async => http.Response('{"status":"ok"}', 200));

  bool isClosed = false;

  @override
  void close() {
    isClosed = true;
    super.close();
  }
}

Widget _wrap(GatewayInfo gateway, [GatewayHealthService? service]) {
  return MaterialApp(
    home: Scaffold(
      body: GatewayStatusRow(gateway: gateway, healthService: service),
    ),
  );
}

void main() {
  testWidgets('shows the address and that the gateway is active', (
    tester,
  ) async {
    final service = _FakeHealthService(
      (address, port) async => GatewayHealthStatus.available,
    );

    await tester.pumpWidget(_wrap(_gateway, service));
    await tester.pumpAndSettle();

    expect(find.text('192.168.0.100'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(service.calls, ['192.168.0.100:10000']);
  });

  testWidgets('shows that the status is being checked', (tester) async {
    final completer = Completer<GatewayHealthStatus>();
    final service = _FakeHealthService((address, port) => completer.future);

    await tester.pumpWidget(_wrap(_gateway, service));

    expect(find.text('Checking...'), findsOneWidget);
    expect(find.text('Active'), findsNothing);

    completer.complete(GatewayHealthStatus.available);
    await tester.pumpAndSettle();

    expect(find.text('Checking...'), findsNothing);
    expect(find.text('Active'), findsOneWidget);
  });

  final labels = <GatewayHealthStatus, String>{
    GatewayHealthStatus.unavailable: 'Unavailable',
    GatewayHealthStatus.timeout: 'Not responding',
    GatewayHealthStatus.networkError: 'Unreachable',
  };

  labels.forEach((status, label) {
    testWidgets('shows "$label" when the status is ${status.name}', (
      tester,
    ) async {
      final service = _FakeHealthService((address, port) async => status);

      await tester.pumpWidget(_wrap(_gateway, service));
      await tester.pumpAndSettle();

      expect(find.text(label), findsOneWidget);
      expect(find.text('Active'), findsNothing);
    });
  });

  testWidgets('shows Unavailable when the check throws', (tester) async {
    final service = _FakeHealthService((address, port) async => throw 'boom');

    await tester.pumpWidget(_wrap(_gateway, service));
    await tester.pumpAndSettle();

    expect(find.text('Unavailable'), findsOneWidget);
  });

  testWidgets('checks the new gateway when the gateway changes', (
    tester,
  ) async {
    final service = _FakeHealthService(
      (address, port) async => GatewayHealthStatus.available,
    );

    await tester.pumpWidget(_wrap(_gateway, service));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_wrap(_otherGateway, service));
    await tester.pumpAndSettle();

    expect(find.text('192.168.0.101'), findsOneWidget);
    expect(service.calls, ['192.168.0.100:10000', '192.168.0.101:8080']);
  });

  testWidgets('ignores a late response of the previous gateway', (
    tester,
  ) async {
    final first = Completer<GatewayHealthStatus>();
    final second = Completer<GatewayHealthStatus>();
    final service = _FakeHealthService(
      (address, port) =>
          address == '192.168.0.100' ? first.future : second.future,
    );

    await tester.pumpWidget(_wrap(_gateway, service));
    await tester.pumpWidget(_wrap(_otherGateway, service));

    second.complete(GatewayHealthStatus.unavailable);
    await tester.pumpAndSettle();
    first.complete(GatewayHealthStatus.available);
    await tester.pumpAndSettle();

    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('Active'), findsNothing);
  });
  group('GatewayStatusRow resource management', () {
    testWidgets('closes its own health service when disposed', (tester) async {
      final trackingClient = _TrackingClient();

      addTearDown(() {
        if (!trackingClient.isClosed) {
          trackingClient.close();
        }
      });

      await http.runWithClient(() async {
        await tester.pumpWidget(_wrap(_gateway));
        await tester.pumpAndSettle();

        expect(find.text('Active'), findsOneWidget);
        expect(trackingClient.isClosed, isFalse);

        await tester.pumpWidget(const SizedBox.shrink());

        expect(trackingClient.isClosed, isTrue);
      }, () => trackingClient);
    });

    testWidgets('does not close an externally provided health service', (
      tester,
    ) async {
      final service = _FakeHealthService(
        (address, port) async => GatewayHealthStatus.available,
      );
      addTearDown(service.close);

      await tester.pumpWidget(_wrap(_gateway, service));
      await tester.pumpAndSettle();

      expect(service.isClosed, isFalse);

      await tester.pumpWidget(const SizedBox.shrink());

      expect(service.isClosed, isFalse);
    });
  });
}

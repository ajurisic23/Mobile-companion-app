import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_companion_app/features/gateway/models/connection_failure.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_connection_service.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_health_service.dart';

GatewayConnectionService _serviceWith(MockClient client) {
  return GatewayConnectionService(
    healthService: GatewayHealthService(client: client),
  );
}

Matcher _failureOfType(ConnectionFailureType type) {
  return throwsA(isA<ConnectionFailure>().having((f) => f.type, 'type', type));
}

class TrackingClient extends MockClient {
  TrackingClient()
    : super((request) async => http.Response('{"status":"ok"}', 200));

  bool isClosed = false;

  @override
  void close() {
    isClosed = true;
    super.close();
  }
}

class TrackingHealthService extends GatewayHealthService {
  TrackingHealthService({required http.Client client}) : super(client: client);

  bool isClosed = false;

  @override
  void close() {
    isClosed = true;
    super.close();
  }
}

void main() {
  test('succeeds when the gateway reports status ok', () async {
    final service = _serviceWith(
      MockClient((request) async => http.Response('{"status": "ok"}', 200)),
    );

    await service.connect('192.168.0.100', '8080');
  });

  test('uses the address, port and path that the user entered', () async {
    Uri? requested;
    final service = _serviceWith(
      MockClient((request) async {
        requested = request.url;
        return http.Response('{"status": "ok"}', 200);
      }),
    );

    await service.connect('192.168.0.100', '8080');

    expect(requested?.host, '192.168.0.100');
    expect(requested?.port, 8080);
    expect(requested?.path, '/api/v1/health');
  });

  test('uses the default port when the port is empty', () async {
    Uri? requested;
    final service = _serviceWith(
      MockClient((request) async {
        requested = request.url;
        return http.Response('{"status": "ok"}', 200);
      }),
    );

    await service.connect('192.168.0.100', '');

    expect(requested?.port, GatewayConnectionService.defaultPort);
  });

  test('throws a timeout failure when the gateway does not respond', () async {
    final service = _serviceWith(
      MockClient((request) async => throw TimeoutException('slow')),
    );

    await expectLater(
      service.connect('192.168.0.100', ''),
      _failureOfType(ConnectionFailureType.timeout),
    );
  });

  test('throws a network failure on a socket error', () async {
    final service = _serviceWith(
      MockClient((request) async => throw const SocketException('unreachable')),
    );

    await expectLater(
      service.connect('192.168.0.100', ''),
      _failureOfType(ConnectionFailureType.networkUnavailable),
    );
  });

  test('throws an unavailable failure on a non-success HTTP status', () async {
    final service = _serviceWith(
      MockClient((request) async => http.Response('error', 500)),
    );

    await expectLater(
      service.connect('192.168.0.100', ''),
      _failureOfType(ConnectionFailureType.unavailable),
    );
  });

  test('throws an unavailable failure when the status is not ok', () async {
    final service = _serviceWith(
      MockClient((request) async => http.Response('{"status": "error"}', 200)),
    );

    await expectLater(
      service.connect('192.168.0.100', ''),
      _failureOfType(ConnectionFailureType.unavailable),
    );
  });

  test('throws an unavailable failure when the response is not JSON', () async {
    final service = _serviceWith(
      MockClient((request) async => http.Response('not json', 200)),
    );

    await expectLater(
      service.connect('192.168.0.100', ''),
      _failureOfType(ConnectionFailureType.unavailable),
    );
  });
  group('GatewayConnectionService resource management', () {
    test('closes an internally created health service', () {
      final trackingClient = TrackingClient();

      addTearDown(() {
        if (!trackingClient.isClosed) {
          trackingClient.close();
        }
      });

      http.runWithClient(() {
        final service = GatewayConnectionService();

        expect(trackingClient.isClosed, isFalse);

        service.close();

        expect(trackingClient.isClosed, isTrue);
      }, () => trackingClient);
    });

    test('does not close an externally provided health service', () async {
      final trackingClient = TrackingClient();
      addTearDown(trackingClient.close);

      final healthService = TrackingHealthService(client: trackingClient);
      addTearDown(healthService.close);

      final service = GatewayConnectionService(healthService: healthService);

      service.close();

      expect(healthService.isClosed, isFalse);
      expect(trackingClient.isClosed, isFalse);

      final result = await healthService.checkHealth(
        address: '192.168.0.100',
        port: 10000,
      );

      expect(result, GatewayHealthStatus.available);
    });
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_companion_app/features/gateway/services/gateway_health_service.dart';

import 'dart:io';

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

void main() {
  const address = '192.168.0.100';
  const port = 10000;

  test('Returns available when gateway health status is ok', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(
        request.url.toString(),
        'http://192.168.0.100:10000/api/v1/health',
      );

      return http.Response('{"status":"ok"}', 200);
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(address: address, port: port);

    expect(result, GatewayHealthStatus.available);
    client.close();
  });

  test('Returns unavailable for HTTP 500', () async {
    final client = MockClient((request) async {
      return http.Response('{"status":"error"}', 500);
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(address: address, port: port);

    expect(result, GatewayHealthStatus.unavailable);
    client.close();
  });

  test('Returns unavailable when JSON status is not ok', () async {
    final client = MockClient((request) async {
      return http.Response('{"status":"error"}', 200);
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(address: address, port: port);

    expect(result, GatewayHealthStatus.unavailable);
    client.close();
  });

  test('Returns unavailable for invalid JSON', () async {
    final client = MockClient((request) async {
      return http.Response('invalid json', 200);
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(address: address, port: port);

    expect(result, GatewayHealthStatus.unavailable);
    client.close();
  });

  test('Returns networkError when gateway cannot be reached', () async {
    final client = MockClient((request) async {
      throw http.ClientException('Connection failed');
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(address: address, port: port);

    expect(result, GatewayHealthStatus.networkError);
    client.close();
  });

  test('Returns timeout when request times out', () async {
    final client = MockClient((request) async {
      throw TimeoutException('Request timed out');
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(address: address, port: port);

    expect(result, GatewayHealthStatus.timeout);
    client.close();
  });
  group('fetchGatewayHealth', () {
    test('Returns gateway health model for a valid response', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.host, address);
        expect(request.url.port, port);
        expect(request.url.path, '/api/v1/health');

        return http.Response('''
          {
            "status": "ok",
            "version": "1.0.0",
            "ports": {"can0": true},
            "transmitter": {"running": true},
            "mqtt": {"connected": true},
            "gnss": {"enabled": false}
          }
        ''', 200);
      });
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      final result = await service.fetchGatewayHealth(
        address: address,
        port: port,
      );

      expect(result.status, 'ok');
      expect(result.version, '1.0.0');
      expect(result.ports, {'can0': true});
      expect(result.transmitter, {'running': true});
      expect(result.mqtt, {'connected': true});
      expect(result.gnss, {'enabled': false});
    });

    test('Uses the default gateway address and port', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'http://192.168.0.100:10000/api/v1/health',
        );

        return http.Response('{"status":"ok"}', 200);
      });
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      await service.fetchGatewayHealth();
    });

    test('Preserves model defaults for missing fields', () async {
      final client = MockClient((request) async => http.Response('{}', 200));
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);
      final result = await service.fetchGatewayHealth();

      expect(result.status, 'unknown');
      expect(result.version, '');
      expect(result.ports, isEmpty);
      expect(result.transmitter, isEmpty);
      expect(result.mqtt, isEmpty);
      expect(result.gnss, isEmpty);
    });

    test('Preserves the externally provided HTTP client', () {
      final client = MockClient((request) async => http.Response('{}', 200));
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      expect(service.client, same(client));
    });

    test('Throws the existing error for HTTP 500', () async {
      final client = MockClient((request) async => http.Response('Error', 500));
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      await expectLater(
        service.fetchGatewayHealth(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            'Exception: Neuspjelo spajanje na gateway: '
                'Exception: Greška na serveru: 500',
          ),
        ),
      );
    });

    test('Throws the existing timeout error', () async {
      final client = MockClient(
        (request) async => throw TimeoutException('Timeout'),
      );
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      await expectLater(
        service.fetchGatewayHealth(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            'Exception: Isteklo vrijeme spajanja na gateway (Timeout)',
          ),
        ),
      );
    });

    test('Throws the existing socket error', () async {
      final client = MockClient(
        (request) async => throw const SocketException('Network unreachable'),
      );
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      await expectLater(
        service.fetchGatewayHealth(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            'Exception: Gateway nije dostupan na mreži',
          ),
        ),
      );
    });

    test('Throws the existing HTTP client error', () async {
      final client = MockClient(
        (request) async => throw http.ClientException('Connection failed'),
      );
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      await expectLater(
        service.fetchGatewayHealth(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            'Exception: Mrežna greška pri spajanju na gateway',
          ),
        ),
      );
    });

    test('Throws the existing error for invalid JSON', () async {
      final client = MockClient(
        (request) async => http.Response('invalid json', 200),
      );
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      await expectLater(
        service.fetchGatewayHealth(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            'Exception: Neispravan format podataka s gatewaya',
          ),
        ),
      );
    });

    test('Rejects an unexpected JSON structure', () async {
      final client = MockClient((request) async => http.Response('[]', 200));
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      await expectLater(
        service.fetchGatewayHealth(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Neuspjelo spajanje na gateway:'),
          ),
        ),
      );
    });

    test('Rejects invalid model field types', () async {
      final client = MockClient(
        (request) async => http.Response('{"status":123}', 200),
      );
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      await expectLater(
        service.fetchGatewayHealth(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Neuspjelo spajanje na gateway:'),
          ),
        ),
      );
    });
  });
  group('GatewayHealthService resource management', () {
    test('closes an internally created HTTP client', () {
      final trackingClient = TrackingClient();

      addTearDown(() {
        if (!trackingClient.isClosed) {
          trackingClient.close();
        }
      });

      http.runWithClient(() {
        final service = GatewayHealthService();

        expect(trackingClient.isClosed, isFalse);

        service.close();

        expect(trackingClient.isClosed, isTrue);
      }, () => trackingClient);
    });

    test('does not close an externally provided HTTP client', () async {
      final trackingClient = TrackingClient();
      addTearDown(trackingClient.close);

      final service = GatewayHealthService(client: trackingClient);

      service.close();

      expect(trackingClient.isClosed, isFalse);

      final response = await trackingClient.get(
        Uri.parse('http://$address:$port/api/v1/health'),
      );

      expect(response.statusCode, 200);
    });
  });

  test(
    'Returns unavailable when the HTTP client throws FormatException',
    () async {
      final client = MockClient(
        (request) async => throw const FormatException('Invalid response'),
      );
      addTearDown(client.close);

      final service = GatewayHealthService(client: client);

      final result = await service.checkHealth(address: address, port: port);

      expect(result, GatewayHealthStatus.unavailable);
    },
  );
}

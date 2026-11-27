import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_companion_app/core/network/api_client.dart';
import 'package:mobile_companion_app/core/network/network_config.dart';
import 'package:mobile_companion_app/core/network/network_exception.dart';

Matcher failureOfType(NetworkFailureType type) {
  return isA<NetworkException>().having((error) => error.type, 'type', type);
}

class TrackingClient extends MockClient {
  TrackingClient() : super((request) async => http.Response('OK', 200));

  bool isClosed = false;

  @override
  void close() {
    isClosed = true;
    super.close();
  }
}

void main() {
  final uri = Uri.parse('http://192.168.0.100:10000/api/v1/test');

  group('ApiClient configuration', () {
    test('uses the default request timeout', () {
      final client = ApiClient();
      addTearDown(client.close);

      expect(client.timeout, NetworkConfig.requestTimeout);
    });

    test('supports a custom request timeout', () {
      final client = ApiClient(timeout: const Duration(milliseconds: 50));
      addTearDown(client.close);

      expect(client.timeout, const Duration(milliseconds: 50));
    });
  });

  group('ApiClient URI construction', () {
    test('builds an HTTP URI', () {
      final result = ApiClient.buildUri(
        host: '192.168.0.100',
        port: 10000,
        path: '/api/v1/health',
      );

      expect(result.toString(), 'http://192.168.0.100:10000/api/v1/health');
    });

    test('supports a custom host, port and path', () {
      final result = ApiClient.buildUri(
        host: 'localhost',
        port: 8080,
        path: '/configuration',
      );

      expect(result.host, 'localhost');
      expect(result.port, 8080);
      expect(result.path, '/configuration');
    });

    test('supports HTTPS', () {
      final result = ApiClient.buildUri(
        host: 'example.com',
        port: 443,
        path: '/api',
        scheme: 'https',
      );

      expect(result.scheme, 'https');
    });

    test('supports query parameters', () {
      final result = ApiClient.buildUri(
        host: 'localhost',
        port: 8080,
        path: '/api',
        queryParameters: {'port': 'can0', 'name': 'Engine speed'},
      );

      expect(result.queryParameters['port'], 'can0');
      expect(result.queryParameters['name'], 'Engine speed');
    });
  });

  group('ApiClient HTTP methods', () {
    for (final method in ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']) {
      test('executes a $method request', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, method);
          expect(request.url, uri);

          return http.Response('{"status":"ok"}', 200);
        });
        addTearDown(mockClient.close);

        final client = ApiClient(client: mockClient);

        final response = await switch (method) {
          'GET' => client.get(uri),
          'POST' => client.post(uri),
          'PUT' => client.put(uri),
          'PATCH' => client.patch(uri),
          'DELETE' => client.delete(uri),
          _ => throw StateError('Unsupported method'),
        };

        expect(response.statusCode, 200);
        expect(response.body, '{"status":"ok"}');
      });
    }

    test('forwards custom request headers', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['accept'], 'application/json');

        return http.Response('{}', 200);
      });
      addTearDown(mockClient.close);

      final client = ApiClient(client: mockClient);

      await client.get(uri, headers: {'Accept': 'application/json'});
    });

    for (final method in ['POST', 'PUT', 'PATCH', 'DELETE']) {
      test('forwards the request body for $method', () async {
        const body = '{"enabled":true}';

        final mockClient = MockClient((request) async {
          expect(request.method, method);
          expect(request.body, body);
          expect(request.headers['content-type'], 'application/json');

          return http.Response('{}', 200);
        });
        addTearDown(mockClient.close);

        final client = ApiClient(client: mockClient);
        final headers = {'Content-Type': 'application/json'};

        await switch (method) {
          'POST' => client.post(uri, headers: headers, body: body),
          'PUT' => client.put(uri, headers: headers, body: body),
          'PATCH' => client.patch(uri, headers: headers, body: body),
          'DELETE' => client.delete(uri, headers: headers, body: body),
          _ => throw StateError('Unsupported method'),
        };
      });
    }
  });

  group('ApiClient HTTP status handling', () {
    for (final status in [200, 201, 202, 204, 299]) {
      test('accepts HTTP status $status', () async {
        final mockClient = MockClient(
          (request) async => http.Response('', status),
        );
        addTearDown(mockClient.close);

        final client = ApiClient(client: mockClient);

        final response = await client.get(uri);

        expect(response.statusCode, status);
      });
    }

    for (final status in [199, 300, 400, 401, 403, 404, 500, 503]) {
      test('rejects HTTP status $status', () async {
        final mockClient = MockClient(
          (request) async => http.Response('Error', status),
        );
        addTearDown(mockClient.close);

        final client = ApiClient(client: mockClient);

        await expectLater(
          client.get(uri),
          throwsA(
            isA<NetworkException>()
                .having(
                  (error) => error.type,
                  'type',
                  NetworkFailureType.badStatus,
                )
                .having((error) => error.statusCode, 'statusCode', status),
          ),
        );
      });
    }
  });

  group('ApiClient network failures', () {
    test('maps a timeout exception', () async {
      final mockClient = MockClient(
        (request) async => throw TimeoutException('Slow response'),
      );
      addTearDown(mockClient.close);

      final client = ApiClient(client: mockClient);

      await expectLater(
        client.get(uri),
        throwsA(failureOfType(NetworkFailureType.timeout)),
      );
    });

    test('enforces the configured request timeout', () async {
      final completer = Completer<http.Response>();

      final mockClient = MockClient((request) => completer.future);
      addTearDown(mockClient.close);

      final client = ApiClient(
        client: mockClient,
        timeout: const Duration(milliseconds: 20),
      );

      try {
        await expectLater(
          client.get(uri),
          throwsA(failureOfType(NetworkFailureType.timeout)),
        );
      } finally {
        completer.complete(http.Response('{}', 200));
      }
    });

    test('maps a socket exception', () async {
      final mockClient = MockClient(
        (request) async => throw const SocketException('Network unreachable'),
      );
      addTearDown(mockClient.close);

      final client = ApiClient(client: mockClient);

      await expectLater(
        client.get(uri),
        throwsA(failureOfType(NetworkFailureType.network)),
      );
    });

    test('maps an HTTP client exception', () async {
      final mockClient = MockClient(
        (request) async => throw http.ClientException('Connection failed'),
      );
      addTearDown(mockClient.close);

      final client = ApiClient(client: mockClient);

      await expectLater(
        client.get(uri),
        throwsA(failureOfType(NetworkFailureType.network)),
      );
    });

    test('preserves the original exception', () async {
      final cause = http.ClientException('Connection failed');

      final mockClient = MockClient((request) async => throw cause);
      addTearDown(mockClient.close);

      final client = ApiClient(client: mockClient);

      await expectLater(
        client.get(uri),
        throwsA(
          isA<NetworkException>().having(
            (error) => error.cause,
            'cause',
            same(cause),
          ),
        ),
      );
    });
  });

  group('ApiClient JSON decoding', () {
    test('decodes a JSON object', () {
      final response = http.Response('{"status":"ok"}', 200);

      expect(ApiClient.decodeJson(response), {'status': 'ok'});
    });

    test('decodes a JSON array', () {
      final response = http.Response('[1,2,3]', 200);

      expect(ApiClient.decodeJson(response), [1, 2, 3]);
    });

    test('decodes a JSON primitive', () {
      final response = http.Response('true', 200);

      expect(ApiClient.decodeJson(response), isTrue);
    });

    test('decodes JSON null', () {
      final response = http.Response('null', 200);

      expect(ApiClient.decodeJson(response), isNull);
    });

    test('rejects invalid JSON', () {
      final response = http.Response('invalid json', 200);

      expect(
        () => ApiClient.decodeJson(response),
        throwsA(failureOfType(NetworkFailureType.invalidResponse)),
      );
    });

    test('rejects an empty body when JSON decoding is requested', () {
      final response = http.Response('', 204);

      expect(
        () => ApiClient.decodeJson(response),
        throwsA(failureOfType(NetworkFailureType.invalidResponse)),
      );
    });
  });

  group('ApiClient resource management', () {
    test('does not close an externally provided HTTP client', () async {
      final mockClient = TrackingClient();
      addTearDown(mockClient.close);

      final client = ApiClient(client: mockClient);

      client.close();

      expect(mockClient.isClosed, isFalse);

      final response = await mockClient.get(uri);

      expect(response.statusCode, 200);
    });

    test('closes an internally created HTTP client', () {
      final trackingClient = TrackingClient();

      addTearDown(() {
        if (!trackingClient.isClosed) {
          trackingClient.close();
        }
      });

      http.runWithClient(() {
        final client = ApiClient();

        expect(trackingClient.isClosed, isFalse);

        client.close();

        expect(trackingClient.isClosed, isTrue);
      }, () => trackingClient);
    });
  });
}

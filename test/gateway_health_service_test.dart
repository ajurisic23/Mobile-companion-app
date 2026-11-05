
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_companion_app/features/gateway/services/gateway_health_service.dart';

void main() {
  test('Returns true when gateway responds with HTTP 200', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(
        request.url.toString(),
        'http://192.168.1.10:8080/api/v1/health',
      );

      return http.Response('OK', 200);
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(
      address: '192.168.1.10',
      port: 8080,
    );

    expect(result, isTrue);
  });


  test('Returns false when gateway is unreachable', () async {
    final client = MockClient((request) async {
      throw Exception('Connection failed');
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(
      address: '192.168.1.10',
      port: 8080,
    );

    expect(result, isFalse);
  });


  test('Returns false when gateway is unreachable', () async {
    final client = MockClient((request) async {
      throw Exception('Connection failed');
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(
      address: '192.168.1.10',
      port: 8080,
    );

    expect(result, isFalse);
  });

}


import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_companion_app/features/gateway/services/gateway_health_service.dart';

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

    final result = await service.checkHealth(
      address: address,
      port: port,
    );

    expect(result, GatewayHealthStatus.available);
    client.close();
  });

  test('Returns unavailable for HTTP 500', () async {
    final client = MockClient((request) async {
      return http.Response('{"status":"error"}', 500);
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(
      address: address,
      port: port,
    );

    expect(result, GatewayHealthStatus.unavailable);
    client.close();
  });

  test('Returns unavailable when JSON status is not ok', () async {
    final client = MockClient((request) async {
      return http.Response('{"status":"error"}', 200);
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(
      address: address,
      port: port,
    );

    expect(result, GatewayHealthStatus.unavailable);
    client.close();
  });

  test('Returns unavailable for invalid JSON', () async {
    final client = MockClient((request) async {
      return http.Response('invalid json', 200);
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(
      address: address,
      port: port,
    );

    expect(result, GatewayHealthStatus.unavailable);
    client.close();
  });

  test('Returns networkError when gateway cannot be reached', () async {
    final client = MockClient((request) async {
      throw http.ClientException('Connection failed');
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(
      address: address,
      port: port,
    );

    expect(result, GatewayHealthStatus.networkError);
    client.close();
  });

  test('Returns timeout when request times out', () async {
    final client = MockClient((request) async {
      throw TimeoutException('Request timed out');
    });

    final service = GatewayHealthService(client: client);

    final result = await service.checkHealth(
      address: address,
      port: port,
    );

    expect(result, GatewayHealthStatus.timeout);
    client.close();
  });
}

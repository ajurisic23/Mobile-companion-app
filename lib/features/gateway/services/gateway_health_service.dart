
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

enum GatewayHealthStatus {
  available,
  unavailable,
  timeout,
  networkError,
}

class GatewayHealthService {
  final http.Client client;

  GatewayHealthService({http.Client? client})
      : client = client ?? http.Client();

  Future<GatewayHealthStatus> checkHealth({
    required String address,
    required int port,
  }) async {
    final uri = Uri(
      scheme: 'http',
      host: address,
      port: port,
      path: '/api/v1/health',
    );

    try {
      final response = await client.get(uri).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return GatewayHealthStatus.unavailable;
      }

      final dynamic data = jsonDecode(response.body);

      if (data is Map && data['status'] == 'ok') {
        return GatewayHealthStatus.available;
      }

      return GatewayHealthStatus.unavailable;
    } on TimeoutException {
      return GatewayHealthStatus.timeout;
    } on SocketException {
      return GatewayHealthStatus.networkError;
    } on http.ClientException {
      return GatewayHealthStatus.networkError;
    } on FormatException {
      return GatewayHealthStatus.unavailable;
    }
  }
}

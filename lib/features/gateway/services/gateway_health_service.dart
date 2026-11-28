import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/network/network_exception.dart';
import '../models/gateway_health_model.dart';

enum GatewayHealthStatus { available, unavailable, timeout, networkError }

class GatewayHealthService {
  static const String _healthPath = '/api/v1/health';
  final http.Client client;
  final bool _ownsClient;

  late final ApiClient _apiClient = ApiClient(client: client);

  GatewayHealthService({http.Client? client})
    : client = client ?? http.Client(),
      _ownsClient = client == null;

  void close() {
    if (_ownsClient) {
      client.close();
    }
  }

  Future<GatewayHealthStatus> checkHealth({
    required String address,
    required int port,
  }) async {
    final uri = ApiClient.buildUri(
      host: address,
      port: port,
      path: _healthPath,
    );

    try {
      final response = await _apiClient.get(uri);
      final data = ApiClient.decodeJson(response);

      if (data is Map && data['status'] == 'ok') {
        return GatewayHealthStatus.available;
      }

      return GatewayHealthStatus.unavailable;
    } on NetworkException catch (error) {
      return switch (error.type) {
        NetworkFailureType.timeout => GatewayHealthStatus.timeout,
        NetworkFailureType.network => GatewayHealthStatus.networkError,
        NetworkFailureType.badStatus => GatewayHealthStatus.unavailable,
        NetworkFailureType.invalidResponse => GatewayHealthStatus.unavailable,
      };
    } on FormatException {
      return GatewayHealthStatus.unavailable;
    }
  }

  Future<GatewayHealthModel> fetchGatewayHealth({
    String address = '192.168.0.100',
    int port = 10000,
  }) async {
    final uri = ApiClient.buildUri(
      host: address,
      port: port,
      path: _healthPath,
    );

    try {
      final response = await _apiClient.get(uri);

      final Map<String, dynamic> jsonData = ApiClient.decodeJson(response);

      return GatewayHealthModel.fromJson(jsonData);
    } on NetworkException catch (error) {
      switch (error.type) {
        case NetworkFailureType.timeout:
          throw Exception('Isteklo vrijeme spajanja na gateway (Timeout)');

        case NetworkFailureType.network:
          if (error.cause is SocketException) {
            throw Exception('Gateway nije dostupan na mreži');
          }

          throw Exception('Mrežna greška pri spajanju na gateway');

        case NetworkFailureType.badStatus:
          throw Exception(
            'Neuspjelo spajanje na gateway: '
            'Exception: Greška na serveru: ${error.statusCode}',
          );

        case NetworkFailureType.invalidResponse:
          throw Exception('Neispravan format podataka s gatewaya');
      }
    } on FormatException {
      throw Exception('Neispravan format podataka s gatewaya');
    } catch (e) {
      throw Exception('Neuspjelo spajanje na gateway: $e');
    }
  }
}

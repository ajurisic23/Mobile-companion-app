import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/network/network_exception.dart';
import '../models/can_port.dart';

enum CanPortsFailureType { timeout, network, unavailable, invalidResponse }

class CanPortsException implements Exception {
  const CanPortsException(this.type);

  final CanPortsFailureType type;

  String get message => switch (type) {
    CanPortsFailureType.timeout => 'The gateway did not respond in time. Check the connection and try again.',
    CanPortsFailureType.network =>
      'Could not reach the gateway. Check that you are on the same network.',
    CanPortsFailureType.unavailable =>
      'The gateway could not provide the CAN ports.',
    CanPortsFailureType.invalidResponse =>
      'The gateway returned an unexpected response.',
  };

  @override
  String toString() => 'CanPortsException: $message';
}

class CanPortsService {
  CanPortsService({http.Client? client})
    : _apiClient = ApiClient(client: client);

  final ApiClient _apiClient;

  Future<List<CanPort>> fetchPorts({
    required String host,
    required int port,
  }) async {
    final uri = ApiClient.buildUri(
      host: host,
      port: port,
      path: '/api/v1/can/ports',
    );

    try {
      final response = await _apiClient.get(uri);
      final data = ApiClient.decodeJson(response);

      return CanPort.listFromJson(data);
    } on NetworkException catch (error) {
      throw CanPortsException(switch (error.type) {
        NetworkFailureType.timeout => CanPortsFailureType.timeout,
        NetworkFailureType.network => CanPortsFailureType.network,
        NetworkFailureType.badStatus => CanPortsFailureType.unavailable,
        NetworkFailureType.invalidResponse =>
          CanPortsFailureType.invalidResponse,
      });
    } on FormatException {
      throw const CanPortsException(CanPortsFailureType.invalidResponse);
    }
  }
}

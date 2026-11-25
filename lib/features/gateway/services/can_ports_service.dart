import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/can_port.dart';

enum CanPortsFailureType {
  timeout,
  network,
  unavailable,
  invalidResponse,
}

class CanPortsException implements Exception {
  const CanPortsException(this.type);

  final CanPortsFailureType type;

  String get message => switch (type) {
    CanPortsFailureType.timeout =>
    'The gateway did not respond in time. Check the connection and try again.',
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
  CanPortsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<CanPort>> fetchPorts({
    required String host,
    required int port,
  }) async {
    final uri = Uri(
      scheme: 'http',
      host: host,
      port: port,
      path: '/api/v1/can/ports',
    );

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw const CanPortsException(CanPortsFailureType.timeout);
    } on SocketException {
      throw const CanPortsException(CanPortsFailureType.network);
    } on http.ClientException {
      throw const CanPortsException(CanPortsFailureType.network);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const CanPortsException(CanPortsFailureType.unavailable);
    }

    try {
      return CanPort.listFromJson(jsonDecode(response.body));
    } on FormatException {
      throw const CanPortsException(CanPortsFailureType.invalidResponse);
    }
  }
}
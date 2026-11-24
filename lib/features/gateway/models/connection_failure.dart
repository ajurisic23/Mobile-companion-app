import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

enum ConnectionFailureType {
  timeout,
  networkUnavailable,
  connectionRefused,
  unknownHost,
  badStatus,
  invalidResponse,
  unavailable,
  unknown,
}

class ConnectionFailure implements Exception {
  const ConnectionFailure(this.type, {this.statusCode});

  final ConnectionFailureType type;

  final int? statusCode;

  String get message => switch (type) {
    ConnectionFailureType.timeout =>
    'The gateway did not respond in time. Check that you are close '
        'enough and connected to the gateway Wi-Fi, then try again.',
    ConnectionFailureType.networkUnavailable =>
    'Cannot reach the gateway. Check that your phone is connected '
        'to the gateway Wi-Fi network.',
    ConnectionFailureType.connectionRefused =>
    'The device refused the connection. Check the port number.',
    ConnectionFailureType.unknownHost =>
    'The address was not found. Check that it is typed correctly.',
    ConnectionFailureType.badStatus => statusCode == 404
        ? 'The device responded, but it does not look like a CAN '
        'gateway. Check the address and port.'
        : 'The device responded with an unexpected status'
        '${statusCode == null ? '' : ' ($statusCode)'}. '
        'Check the address and port.',
    ConnectionFailureType.invalidResponse =>
    'The device responded, but the response was not understood. '
        'Check that this is a CAN gateway.',
    ConnectionFailureType.unavailable =>
    'The gateway is not available. Check the address and port, '
        'then try again.',
    ConnectionFailureType.unknown =>
    'Something went wrong while connecting. Please try again.',
  };

  factory ConnectionFailure.fromError(Object error) {
    if (error is ConnectionFailure) return error;

    if (error is TimeoutException) {
      return const ConnectionFailure(ConnectionFailureType.timeout);
    }

    if (error is SocketException) {
      return ConnectionFailure(
        _fromNetworkText(error.message, error.osError?.errorCode),
      );
    }

    if (error is http.ClientException) {
      return ConnectionFailure(_fromNetworkText(error.message, null));
    }

    if (error is FormatException) {
      return const ConnectionFailure(ConnectionFailureType.invalidResponse);
    }

    if (error is TypeError) {
      return const ConnectionFailure(ConnectionFailureType.invalidResponse);
    }

    return const ConnectionFailure(ConnectionFailureType.unknown);
  }

  static ConnectionFailureType _fromNetworkText(String message, int? code) {
    final text = message.toLowerCase();

    if (text.contains('failed host lookup')) {
      return ConnectionFailureType.unknownHost;
    }
    if (code == 111 || code == 61 || code == 10061 || text.contains('refused')) {
      return ConnectionFailureType.connectionRefused;
    }
    return ConnectionFailureType.networkUnavailable;
  }
}
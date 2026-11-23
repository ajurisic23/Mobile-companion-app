import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_companion_app/features/gateway/models/connection_failure.dart';

void main() {
  group('ConnectionFailure.fromError', () {
    test('maps a timeout', () {
      final failure = ConnectionFailure.fromError(TimeoutException('slow'));
      expect(failure.type, ConnectionFailureType.timeout);
    });

    test('maps an unknown host', () {
      final failure = ConnectionFailure.fromError(
        const SocketException("Failed host lookup: 'abc'"),
      );
      expect(failure.type, ConnectionFailureType.unknownHost);
    });

    test('maps a refused connection (wrong port)', () {
      final failure = ConnectionFailure.fromError(
        const SocketException(
          'Connection refused',
          osError: OSError('Connection refused', 111),
        ),
      );
      expect(failure.type, ConnectionFailureType.connectionRefused);
    });

    test('maps an unreachable network', () {
      final failure = ConnectionFailure.fromError(
        const SocketException(
          'Network is unreachable',
          osError: OSError('Network is unreachable', 101),
        ),
      );
      expect(failure.type, ConnectionFailureType.networkUnavailable);
    });

    test('maps an http client exception', () {
      final failure = ConnectionFailure.fromError(
        http.ClientException('Connection closed'),
      );
      expect(failure.type, ConnectionFailureType.networkUnavailable);
    });

    test('maps an unreadable response', () {
      final failure = ConnectionFailure.fromError(const FormatException('bad'));
      expect(failure.type, ConnectionFailureType.invalidResponse);
    });

    test('maps anything else to unknown', () {
      final failure = ConnectionFailure.fromError(Exception('something'));
      expect(failure.type, ConnectionFailureType.unknown);
    });

    test('keeps an existing ConnectionFailure unchanged', () {
      const original = ConnectionFailure(
        ConnectionFailureType.badStatus,
        statusCode: 404,
      );
      expect(ConnectionFailure.fromError(original), same(original));
    });
  });

  group('ConnectionFailure.message', () {
    test('gives a specific message for 404', () {
      const failure = ConnectionFailure(
        ConnectionFailureType.badStatus,
        statusCode: 404,
      );
      expect(failure.message, contains('does not look like a CAN gateway'));
    });

    test('includes the status code for other statuses', () {
      const failure = ConnectionFailure(
        ConnectionFailureType.badStatus,
        statusCode: 500,
      );
      expect(failure.message, contains('500'));
    });

    test('every failure type has a non-empty message', () {
      for (final type in ConnectionFailureType.values) {
        expect(ConnectionFailure(type).message, isNotEmpty);
      }
    });
  });
}
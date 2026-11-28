import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/core/network/network_exception.dart';

void main() {
  group('NetworkException', () {
    test('preserves the failure type', () {
      for (final type in NetworkFailureType.values) {
        final exception = NetworkException(type);

        expect(exception.type, type);
      }
    });

    test('preserves the HTTP status code', () {
      const exception = NetworkException(
        NetworkFailureType.badStatus,
        statusCode: 500,
      );

      expect(exception.statusCode, 500);
    });

    test('preserves the original cause', () {
      final cause = Exception('Connection failed');

      final exception = NetworkException(
        NetworkFailureType.network,
        cause: cause,
      );

      expect(exception.cause, same(cause));
    });

    test('allows optional fields to be omitted', () {
      const exception = NetworkException(NetworkFailureType.timeout);

      expect(exception.statusCode, isNull);
      expect(exception.cause, isNull);
    });

    test('implements the Exception interface', () {
      const exception = NetworkException(NetworkFailureType.network);

      expect(exception, isA<Exception>());
    });

    test('provides diagnostic information', () {
      const exception = NetworkException(
        NetworkFailureType.badStatus,
        statusCode: 404,
      );

      expect(exception.toString(), contains('badStatus'));
      expect(exception.toString(), contains('404'));
    });
  });
}

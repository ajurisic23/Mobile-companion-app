import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/validators/gateway_validators.dart';

void main() {
  group('validateGatewayHost', () {
    test('rejects null, empty and whitespace-only values', () {
      expect(validateGatewayHost(null), isNotNull);
      expect(validateGatewayHost(''), isNotNull);
      expect(validateGatewayHost('   '), isNotNull);
    });

    test('accepts valid IPv4 addresses and host names', () {
      expect(validateGatewayHost('192.168.0.100'), isNull);
      expect(validateGatewayHost(' 192.168.0.100 '), isNull);
      expect(validateGatewayHost('localhost'), isNull);
      expect(validateGatewayHost('gateway.local'), isNull);
    });

    test('rejects addresses with a scheme, path, port or spaces', () {
      expect(validateGatewayHost('http://192.168.0.100'), isNotNull);
      expect(validateGatewayHost('192.168.0.100/api'), isNotNull);
      expect(validateGatewayHost('192.168.0.100:80'), isNotNull);
      expect(validateGatewayHost('192.168 0.1'), isNotNull);
    });

    test('rejects invalid IPv4 addresses', () {
      expect(validateGatewayHost('192.168.0.300'), isNotNull);
      expect(validateGatewayHost('192.168.0'), isNotNull);
      expect(validateGatewayHost('192.168.0.1.5'), isNotNull);
      expect(validateGatewayHost('192.168..1'), isNotNull);
    });

    test('rejects invalid host names', () {
      expect(validateGatewayHost('bad_host!'), isNotNull);
      expect(validateGatewayHost('-bad.com'), isNotNull);
    });
  });

  group('validateGatewayPort', () {
    test('treats an empty port as valid (port is optional)', () {
      expect(validateGatewayPort(null), isNull);
      expect(validateGatewayPort(''), isNull);
      expect(validateGatewayPort('   '), isNull);
    });

    test('accepts ports from 1 to 65535', () {
      expect(validateGatewayPort('1'), isNull);
      expect(validateGatewayPort('80'), isNull);
      expect(validateGatewayPort('10000'), isNull);
      expect(validateGatewayPort('65535'), isNull);
    });

    test('rejects ports outside the range', () {
      expect(validateGatewayPort('0'), isNotNull);
      expect(validateGatewayPort('65536'), isNotNull);
    });

    test('rejects values that are not plain numbers', () {
      expect(validateGatewayPort('abc'), isNotNull);
      expect(validateGatewayPort('-1'), isNotNull);
      expect(validateGatewayPort('+80'), isNotNull);
      expect(validateGatewayPort('0x50'), isNotNull);
      expect(validateGatewayPort('8 0'), isNotNull);
      expect(validateGatewayPort('80.5'), isNotNull);
    });
  });
}
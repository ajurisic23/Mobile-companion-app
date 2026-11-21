import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';

void main() {
  const gateway = GatewayInfo(
    name: 'Address 1',
    host: '192.168.0.100',
    port: 80,
  );

  group('toJson and fromJson', () {
    test('toJson contains name, host and port', () {
      expect(gateway.toJson(), {
        'name': 'Address 1',
        'host': '192.168.0.100',
        'port': 80,
      });
    });

    test('fromJson restores what toJson produced', () {
      expect(GatewayInfo.fromJson(gateway.toJson()), gateway);
    });

    test('uses the address as the name when the name is missing or empty', () {
      final missing = GatewayInfo.fromJson({
        'host': '192.168.0.100',
        'port': 80,
      });
      final empty = GatewayInfo.fromJson({
        'name': '  ',
        'host': '192.168.0.100',
        'port': 80,
      });

      expect(missing.name, '192.168.0.100:80');
      expect(empty.name, '192.168.0.100:80');
    });

    test('trims the name and the host', () {
      final parsed = GatewayInfo.fromJson({
        'name': ' Address 1 ',
        'host': ' 192.168.0.100 ',
        'port': 80,
      });

      expect(parsed, gateway);
    });
  });

  group('fromJson with invalid data', () {
    final invalidValues = <String, Object?>{
      'it is null': null,
      'it is a string': 'text',
      'it is a list': [1, 2],
      'the host is missing': {'name': 'A', 'port': 80},
      'the host is empty': {'host': '  ', 'port': 80},
      'the host is not a string': {'host': 5, 'port': 80},
      'the port is missing': {'host': '192.168.0.100'},
      'the port is a string': {'host': '192.168.0.100', 'port': '80'},
      'the port is zero': {'host': '192.168.0.100', 'port': 0},
      'the port is too large': {'host': '192.168.0.100', 'port': 65536},
    };

    invalidValues.forEach((description, json) {
      test('throws a FormatException when $description', () {
        expect(() => GatewayInfo.fromJson(json), throwsFormatException);
      });
    });
  });

  group('comparison', () {
    test('gateways with the same values are equal', () {
      const same = GatewayInfo(
        name: 'Address 1',
        host: '192.168.0.100',
        port: 80,
      );

      expect(gateway, same);
      expect(gateway.hashCode, same.hashCode);
    });

    test('hasSameAddressAs ignores the name', () {
      const renamed = GatewayInfo(
        name: 'Other name',
        host: '192.168.0.100',
        port: 80,
      );

      expect(gateway.hasSameAddressAs(renamed), isTrue);
    });

    test('hasSameAddressAs is false for a different host or port', () {
      const otherHost = GatewayInfo(
        name: 'Address 1',
        host: '192.168.0.101',
        port: 80,
      );
      const otherPort = GatewayInfo(
        name: 'Address 1',
        host: '192.168.0.100',
        port: 81,
      );

      expect(gateway.hasSameAddressAs(otherHost), isFalse);
      expect(gateway.hasSameAddressAs(otherPort), isFalse);
    });
  });
}
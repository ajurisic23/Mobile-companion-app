import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/models/can_port.dart';

void main() {
  const can0 = CanPort(name: 'can0', halName: 'CAN1', enabled: true);
  const can1 = CanPort(name: 'can1', halName: 'CAN2', enabled: true);

  group('fromJson', () {
    test('reads the name, the hal name and the enabled flag', () {
      final port = CanPort.fromJson({
        'name': 'can0',
        'halName': 'CAN1',
        'enabled': true,
      });

      expect(port, can0);
    });

    test('treats a missing enabled flag as enabled', () {
      final port = CanPort.fromJson({'name': 'can0', 'halName': 'CAN1'});

      expect(port.enabled, isTrue);
    });

    test('keeps a disabled port disabled', () {
      final port = CanPort.fromJson({
        'name': 'can0',
        'halName': 'CAN1',
        'enabled': false,
      });

      expect(port.enabled, isFalse);
    });

    test('uses an empty hal name when it is missing', () {
      final port = CanPort.fromJson({'name': 'can0'});

      expect(port.halName, isEmpty);
    });

    test('trims the name', () {
      final port = CanPort.fromJson({'name': ' can0 ', 'halName': 'CAN1'});

      expect(port.name, 'can0');
    });
  });

  group('fromJson with invalid data', () {
    final invalidValues = <String, Object?>{
      'it is null': null,
      'it is a string': 'can0',
      'it is a list': ['can0'],
      'the name is missing': {'halName': 'CAN1'},
      'the name is empty': {'name': '  '},
      'the name is not a string': {'name': 5},
    };

    invalidValues.forEach((description, json) {
      test('throws a FormatException when $description', () {
        expect(() => CanPort.fromJson(json), throwsFormatException);
      });
    });
  });

  group('label', () {
    test('shows the name and the hal name', () {
      expect(can0.label, 'can0 (CAN1)');
    });

    test('shows only the name when the hal name is empty', () {
      const port = CanPort(name: 'can0', halName: '', enabled: true);

      expect(port.label, 'can0');
    });

    test('shows only the name when the hal name is the same', () {
      const port = CanPort(name: 'can0', halName: 'can0', enabled: true);

      expect(port.label, 'can0');
    });
  });

  group('listFromJson', () {
    test('reads the ports from the gateway response', () {
      final ports = CanPort.listFromJson({
        'ports': [
          {'name': 'can0', 'halName': 'CAN1', 'enabled': true},
          {'name': 'can1', 'halName': 'CAN2', 'enabled': true},
        ],
      });

      expect(ports, [can0, can1]);
    });

    test('returns an empty list when there are no ports', () {
      expect(CanPort.listFromJson({'ports': []}), isEmpty);
    });

    test('skips invalid entries and keeps the valid ones', () {
      final ports = CanPort.listFromJson({
        'ports': [
          {'name': 'can0', 'halName': 'CAN1', 'enabled': true},
          'text',
          null,
          {'halName': 'CAN9'},
          {'name': 'can1', 'halName': 'CAN2', 'enabled': true},
        ],
      });

      expect(ports, [can0, can1]);
    });

    final invalidResponses = <String, Object?>{
      'the response is null': null,
      'the response is a list': [1, 2],
      'the ports list is missing': {'other': 1},
      'ports is not a list': {'ports': 'can0'},
    };

    invalidResponses.forEach((description, json) {
      test('throws a FormatException when $description', () {
        expect(() => CanPort.listFromJson(json), throwsFormatException);
      });
    });
  });
}
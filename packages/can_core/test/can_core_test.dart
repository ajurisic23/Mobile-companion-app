import 'package:flutter_test/flutter_test.dart';
import 'package:can_core/can_core.dart';

void main() {
  group('SignalDisplayData', () {
    test('stores all signal properties correctly', () {
      const signal = SignalDisplayData(
        tag: 'engine_speed',
        name: 'Engine speed',
        value: '1244.125',
        unit: 'rpm',
      );

      expect(signal.tag, 'engine_speed');
      expect(signal.name, 'Engine speed');
      expect(signal.value, '1244.125');
      expect(signal.unit, 'rpm');
    });

    test('supports signals without a measurement unit', () {
      const signal = SignalDisplayData(
        tag: 'current_gear',
        name: 'Current gear',
        value: '3',
      );

      expect(signal.value, '3');
      expect(signal.unit, isNull);
    });

    test('preserves negative signal values', () {
      const signal = SignalDisplayData(
        tag: 'temperature',
        name: 'Temperature',
        value: '-15.5',
        unit: 'degC',
      );

      expect(signal.value, '-15.5');
    });

    test('preserves zero signal values', () {
      const signal = SignalDisplayData(
        tag: 'vehicle_speed',
        name: 'Vehicle speed',
        value: '0',
        unit: 'km/h',
      );

      expect(signal.value, '0');
    });

    test('preserves decimal precision', () {
      const signal = SignalDisplayData(
        tag: 'fuel_pressure',
        name: 'Fuel pressure',
        value: '564.3000000000001',
        unit: 'kPa',
      );

      expect(signal.value, '564.3000000000001');
    });
  });
}
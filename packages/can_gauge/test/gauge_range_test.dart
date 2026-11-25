import 'package:flutter_test/flutter_test.dart';
import 'package:can_gauge/models/gauge_range.dart';

void main() {
  group('GaugeRange', () {
    const range = GaugeRange(min: 0, max: 100);

    test('stores minimum and maximum values', () {
      expect(range.min, 0);
      expect(range.max, 100);
    });

    test('normalizes minimum value to zero', () {
      expect(range.normalize(0), 0.0);
    });

    test('normalizes maximum value to one', () {
      expect(range.normalize(100), 1.0);
    });

    test('normalizes midpoint to 0.5', () {
      expect(range.normalize(50), 0.5);
    });

    test('normalizes decimal values correctly', () {
      expect(range.normalize(61.2), closeTo(0.612, 0.0001));
    });

    test('clamps values below minimum to zero', () {
      expect(range.normalize(-20), 0.0);
    });

    test('clamps values above maximum to one', () {
      expect(range.normalize(150), 1.0);
    });

    test('supports ranges with negative minimum', () {
      const temperatureRange = GaugeRange(
        min: -40,
        max: 150,
      );

      expect(temperatureRange.normalize(-40), 0.0);
      expect(temperatureRange.normalize(55), 0.5);
      expect(temperatureRange.normalize(150), 1.0);
    });

    test('rejects equal minimum and maximum', () {
      expect(
            () => GaugeRange(min: 100, max: 100),
        throwsAssertionError,
      );
    });

    test('rejects maximum smaller than minimum', () {
      expect(
            () => GaugeRange(min: 100, max: 0),
        throwsAssertionError,
      );
    });
  });
}
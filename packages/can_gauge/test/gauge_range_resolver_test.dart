import 'package:flutter_test/flutter_test.dart';
import 'package:can_core/can_core.dart';
import 'package:can_gauge/utils/gauge_range_resolver.dart';

void main() {
  SignalDisplayData createSignal({
    String tag = 'test_signal',
    String? unit,
  }) {
    return SignalDisplayData(
      tag: tag,
      name: 'Test signal',
      value: '50',
      unit: unit,
    );
  }

  void expectRange(
      SignalDisplayData signal,
      double min,
      double max,
      ) {
    final range = GaugeRangeResolver.resolve(signal);

    expect(range, isNotNull);
    expect(range!.min, min);
    expect(range.max, max);
  }

  group('GaugeRangeResolver', () {
    test('resolves engine speed by signal tag', () {
      expectRange(
        createSignal(tag: 'engine_speed'),
        0,
        3000,
      );
    });

    test('prioritizes signal tag over measurement unit', () {
      expectRange(
        createSignal(tag: 'engine_speed', unit: '%'),
        0,
        3000,
      );
    });

    test('resolves percentage range', () {
      expectRange(createSignal(unit: '%'), 0, 100);
    });

    test('resolves RPM range', () {
      expectRange(createSignal(unit: 'rpm'), 0, 3000);
    });

    test('resolves vehicle speed range', () {
      expectRange(createSignal(unit: 'km/h'), 0, 160);
    });

    test('resolves temperature range in degC', () {
      expectRange(createSignal(unit: 'degC'), -40, 150);
    });

    test('resolves temperature range in Celsius', () {
      expectRange(createSignal(unit: '°C'), -40, 150);
    });

    test('resolves special exhaust temperature range', () {
      expectRange(
        createSignal(
          tag: 'exhaust_temperature',
          unit: 'degC',
        ),
        -40,
        800,
      );
    });

    test('resolves pressure range', () {
      expectRange(createSignal(unit: 'kPa'), 0, 1000);
    });

    test('resolves torque range', () {
      expectRange(createSignal(unit: 'Nm'), 0, 3000);
    });

    test('handles uppercase measurement units', () {
      expectRange(createSignal(unit: 'RPM'), 0, 3000);
    });

    test('handles whitespace around measurement units', () {
      expectRange(createSignal(unit: '  kPa  '), 0, 1000);
    });

    test('handles uppercase signal tags', () {
      expectRange(
        createSignal(tag: 'ENGINE_SPEED'),
        0,
        3000,
      );
    });

    test('returns null for unknown measurement units', () {
      expect(
        GaugeRangeResolver.resolve(
          createSignal(unit: 'unknown'),
        ),
        isNull,
      );
    });

    test('returns null for signals without a unit', () {
      expect(
        GaugeRangeResolver.resolve(createSignal()),
        isNull,
      );
    });

    test('returns null for blank measurement units', () {
      expect(
        GaugeRangeResolver.resolve(
          createSignal(unit: '   '),
        ),
        isNull,
      );
    });

    test('returns null for cumulative operating hours', () {
      expect(
        GaugeRangeResolver.resolve(
          createSignal(
            tag: 'engine_total_hours',
            unit: 'h',
          ),
        ),
        isNull,
      );
    });

    test('returns null for cumulative distance', () {
      expect(
        GaugeRangeResolver.resolve(
          createSignal(
            tag: 'total_distance',
            unit: 'km',
          ),
        ),
        isNull,
      );
    });
  });
}
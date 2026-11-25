import 'package:can_core/can_core.dart';

import '../models/gauge_range.dart';

class GaugeRangeResolver {
  static GaugeRange? resolve(SignalDisplayData signal) {
    final tag = signal.tag.toLowerCase();
    final unit = signal.unit?.trim().toLowerCase();

    // Signal-specific display ranges.
    switch (tag) {
      case 'engine_speed':
        return const GaugeRange(min: 0, max: 3000);
    }

    // Special temperature ranges.
    if (unit == 'degc' && tag.contains('exhaust')) {
      return const GaugeRange(min: -40, max: 800);
    }

    // Default display ranges based on measurement units.
    switch (unit) {
      case '%':
        return const GaugeRange(min: 0, max: 100);

      case 'rpm':
        return const GaugeRange(min: 0, max: 3000);

      case 'km/h':
        return const GaugeRange(min: 0, max: 160);

      case 'degc':
      case '°c':
        return const GaugeRange(min: -40, max: 150);

      case 'kpa':
        return const GaugeRange(min: 0, max: 1000);

      case 'nm':
        return const GaugeRange(min: 0, max: 3000);

      default:
        return null;
    }
  }
}
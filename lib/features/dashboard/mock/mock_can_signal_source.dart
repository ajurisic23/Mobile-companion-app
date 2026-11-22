
import 'dart:async';
import 'dart:math';

import 'package:can_core/can_core.dart';
import 'mock_can_signals.dart';
import '../interfaces/can_signal_source.dart';

class MockCanSignalSource implements CanSignalSource {
  final Random _random = Random();
  @override
  Stream<List<SignalDisplayData>> get signals async* {
    yield List.of(mockCanSignals);

    yield* Stream.periodic(
      const Duration(seconds: 2),
          (_) => [
        SignalDisplayData(
          tag: 'engine_speed',
          name: 'Engine Speed',
          value: (1200 + _random.nextInt(1000)).toString(),
          unit: 'rpm',
        ),
        SignalDisplayData(
          tag: 'vehicle_speed',
          name: 'Vehicle Speed',
          value: (40 + _random.nextInt(60)).toString(),
          unit: 'km/h',
        ),
        SignalDisplayData(
          tag: 'coolant_temp',
          name: 'Coolant Temperature',
          value: (80 + _random.nextInt(20)).toString(),
          unit: '°C',
        ),
        SignalDisplayData(
          tag: 'fuel_level',
          name: 'Fuel Level',
          value: (60 + _random.nextInt(30)).toString(),
          unit: '%',
        ),
      ],
    );
  }
}

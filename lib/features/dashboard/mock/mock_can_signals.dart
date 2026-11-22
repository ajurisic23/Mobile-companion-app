
import 'package:can_core/can_core.dart';

const mockCanSignals = <SignalDisplayData>[
  SignalDisplayData(
    tag: 'engine_speed',
    name: 'Engine Speed',
    value: '1500',
    unit: 'rpm',
  ),
  SignalDisplayData(
    tag: 'vehicle_speed',
    name: 'Vehicle Speed',
    value: '65',
    unit: 'km/h',
  ),
  SignalDisplayData(
    tag: 'coolant_temp',
    name: 'Coolant Temperature',
    value: '85',
    unit: '°C',
  ),
  SignalDisplayData(
    tag: 'fuel_level',
    name: 'Fuel Level',
    value: '72',
    unit: '%',
  ),
];

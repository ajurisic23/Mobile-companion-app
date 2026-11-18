import 'can_signal.dart';

class CanMessage {
  const CanMessage({
    required this.id,
    required this.category,
    required this.group,
    required this.timestamp,
    required this.variables,
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  final int id;
  final String category;
  final String group;
  final int timestamp;
  final List<CanSignal> variables;
  final double latitude;
  final double longitude;
  final double altitude;
}

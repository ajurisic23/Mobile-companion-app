import 'can_signal.dart';

class CanMessage {
  const CanMessage({
    required this.id,
    required this.category,
    this.group,
    required this.timestamp,
    required this.variables,
    this.latitude,
    this.longitude,
    this.altitude,
  });

  final int id;
  final String category;
  final String? group;
  final int timestamp;
  final List<CanSignal> variables;
  final double? latitude;
  final double? longitude;
  final double? altitude;
}
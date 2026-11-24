class CanPort {
  const CanPort({
    required this.name,
    required this.halName,
    required this.enabled,
  });

  factory CanPort.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('CAN port must be a JSON object.');
    }

    final name = json['name'];
    final halName = json['halName'];
    final enabled = json['enabled'];

    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('CAN port name is missing or invalid.');
    }

    return CanPort(
      name: name.trim(),
      halName: halName is String ? halName.trim() : '',
      enabled: enabled is bool ? enabled : true,
    );
  }

  static List<CanPort> listFromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('CAN ports response must be a JSON object.');
    }

    final ports = json['ports'];
    if (ports is! List) {
      throw const FormatException('CAN ports response has no ports list.');
    }

    final result = <CanPort>[];
    for (final item in ports) {
      try {
        result.add(CanPort.fromJson(item));
      } on FormatException {
        continue;
      }
    }
    return result;
  }

  final String name;
  final String halName;
  final bool enabled;

  String get label =>
      halName.isEmpty || halName == name ? name : '$name ($halName)';

  @override
  bool operator ==(Object other) =>
      other is CanPort &&
          other.name == name &&
          other.halName == halName &&
          other.enabled == enabled;

  @override
  int get hashCode => Object.hash(name, halName, enabled);
}
class GatewayInfo {
  const GatewayInfo({
    required this.name,
    required this.host,
    required this.port,
  });

  factory GatewayInfo.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('Gateway must be a JSON object.');
    }

    final host = json['host'];
    final port = json['port'];
    final name = json['name'];

    if (host is! String || host.trim().isEmpty) {
      throw const FormatException('Gateway host is missing or invalid.');
    }
    if (port is! int || port < 1 || port > 65535) {
      throw const FormatException('Gateway port is missing or invalid.');
    }

    final trimmedHost = host.trim();
    final trimmedName = name is String ? name.trim() : '';

    return GatewayInfo(
      name: trimmedName.isEmpty ? '$trimmedHost:$port' : trimmedName,
      host: trimmedHost,
      port: port,
    );
  }

  final String name;
  final String host;
  final int port;

  String get address => '$host:$port';

  bool hasSameAddressAs(GatewayInfo other) =>
      host == other.host && port == other.port;

  Map<String, dynamic> toJson() => {
    'name': name,
    'host': host,
    'port': port,
  };

  @override
  bool operator ==(Object other) =>
      other is GatewayInfo &&
          other.name == name &&
          other.host == host &&
          other.port == port;

  @override
  int get hashCode => Object.hash(name, host, port);
}
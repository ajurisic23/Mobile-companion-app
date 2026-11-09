class GatewayInfo {
  const GatewayInfo({
    required this.name,
    required this.host,
    required this.port,
  });

  final String name;
  final String host;
  final int port;

  String get address => '$host:$port';
}
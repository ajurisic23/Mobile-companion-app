
class GatewayHealthModel {
  final String status;
  final String version;
  final Map<String, dynamic> ports;
  final Map<String, dynamic> transmitter;
  final Map<String, dynamic> mqtt;
  final Map<String, dynamic> gnss;

  GatewayHealthModel({required this.status,required this.version,required this.ports,required this.transmitter,required this.mqtt,required this.gnss});

  factory GatewayHealthModel.fromJson(Map<String, dynamic> json) {
    return GatewayHealthModel(
      status: json['status'] ?? 'unknown',
      version: json['version'] ?? '',
      ports: json['ports'] ?? {},
      transmitter: json['transmitter'] ?? {},
      mqtt: json['mqtt'] ?? {},
      gnss: json['gnss'] ?? {},
    );
  }

}
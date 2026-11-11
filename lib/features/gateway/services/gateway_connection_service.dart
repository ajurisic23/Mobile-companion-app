import '../models/connection_failure.dart';
import 'gateway_health_service.dart';

class GatewayConnectionService {
  GatewayConnectionService({GatewayHealthService? healthService})
      : _healthService = healthService ?? GatewayHealthService();

  static const int defaultPort = 10000;

  final GatewayHealthService _healthService;

  Future<void> connect(String host, String port) async {
    final portNumber = port.isEmpty ? defaultPort : int.parse(port);

    final status = await _healthService.checkHealth(
      address: host,
      port: portNumber,
    );

    switch (status) {
      case GatewayHealthStatus.available:
        return;
      case GatewayHealthStatus.timeout:
        throw const ConnectionFailure(ConnectionFailureType.timeout);
      case GatewayHealthStatus.networkError:
        throw const ConnectionFailure(ConnectionFailureType.networkUnavailable);
      case GatewayHealthStatus.unavailable:
        throw const ConnectionFailure(ConnectionFailureType.unavailable);
    }
  }
}
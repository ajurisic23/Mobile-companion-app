import '../models/gateway_info.dart';

class DuplicateGatewayException implements Exception {
  const DuplicateGatewayException(this.gateway);

  final GatewayInfo gateway;

  @override
  String toString() =>
      'A gateway with address ${gateway.address} is already saved.';
}

abstract class GatewayRepository {
  Future<List<GatewayInfo>> getAll();

  Future<void> save(GatewayInfo gateway);

  Future<void> update(GatewayInfo original, GatewayInfo updated);

  Future<void> delete(GatewayInfo gateway);
}
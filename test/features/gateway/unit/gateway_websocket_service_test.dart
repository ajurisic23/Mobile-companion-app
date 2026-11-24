import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_websocket_service.dart';

void main() {
  group('GatewayWebSocketService.buildUri', () {
    test('builds the address of the CAN port websocket', () {
      final uri = GatewayWebSocketService.buildUri(
        host: '192.168.0.100',
        port: 10000,
        canPort: 'can0',
      );

      expect(uri.toString(), 'ws://192.168.0.100:10000/api/v1/can/can0/ws');
    });

    test('uses the given host, port and CAN port', () {
      final uri = GatewayWebSocketService.buildUri(
        host: '10.0.0.5',
        port: 8080,
        canPort: 'can1',
      );

      expect(uri.toString(), 'ws://10.0.0.5:8080/api/v1/can/can1/ws');
    });
  });

  test('starts disconnected', () {
    final service = GatewayWebSocketService();

    expect(service.status, GatewayWebSocketStatus.disconnected);
    expect(service.isConnected, isFalse);
  });
}
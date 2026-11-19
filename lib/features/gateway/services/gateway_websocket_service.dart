import 'package:web_socket_channel/web_socket_channel.dart';

enum GatewayWebSocketStatus {
  disconnected,
  connecting,
  connected,
}

class GatewayWebSocketService {
  static const String defaultHost = '192.168.0.100';
  static const int defaultPort = 10000;
  static const String wsPath = '/ws';

  WebSocketChannel? _channel;
  GatewayWebSocketStatus _status = GatewayWebSocketStatus.disconnected;

  GatewayWebSocketStatus get status => _status;
  bool get isConnected => _status == GatewayWebSocketStatus.connected && _channel != null;

  void connect({
    String host = defaultHost,
    int port = defaultPort,
    String path = wsPath,
  }) {
    disconnect();

    _status = GatewayWebSocketStatus.connecting;

    try {
      final normalizedPath = path.startsWith('/') ? path : '/$path';
      final uri = Uri(
        scheme: 'ws',
        host: host,
        port: port,
        path: normalizedPath,
      );

      _channel = WebSocketChannel.connect(uri);
      _status = GatewayWebSocketStatus.connected;
    } catch (e) {
      _channel = null;
      _status = GatewayWebSocketStatus.disconnected;
      print('Greška pri spajanju na WebSocket: $e');
    }
  }

  Stream<dynamic>? get stream => _channel?.stream;

  void disconnect() {
    final existingChannel = _channel;
    _channel = null;
    _status = GatewayWebSocketStatus.disconnected;

    if (existingChannel != null) {
      try {
        existingChannel.sink.close();
      } catch (e) {
        print('Greška pri zatvaranju WebSocket kanala: $e');
      }
    }
  }
}
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

enum GatewayWebSocketStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class GatewayWebSocketService {
  static const String defaultHost = '192.168.0.100';
  static const int defaultPort = 10000;
  static const String wsPath = '/ws';

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  GatewayWebSocketStatus _status = GatewayWebSocketStatus.disconnected;

  GatewayWebSocketStatus get status => _status;
  bool get isConnected =>
      _status == GatewayWebSocketStatus.connected && _channel != null;

  Stream<dynamic>? get stream => _channel?.stream;

  Future<void> connect({
    String host = defaultHost,
    int port = defaultPort,
    String path = wsPath,
  }) async {
    await disconnect();

    _status = GatewayWebSocketStatus.connecting;

    try {
      final normalizedPath = path.startsWith('/') ? path : '/$path';
      final uri = Uri(
        scheme: 'ws',
        host: host,
        port: port,
        path: normalizedPath,
      );

      final channel = WebSocketChannel.connect(uri);
      _channel = channel;

      await channel.ready;

      if (_channel != channel) {
        return;
      }

      _status = GatewayWebSocketStatus.connected;

      _subscription = channel.stream.listen(
            (_) {},
        onError: (Object error, StackTrace stackTrace) {
          print('WebSocket greška na streamu: $error');
          _cleanup(nextStatus: GatewayWebSocketStatus.error);
        },
        onDone: () {
          final statusAfterClose = _status == GatewayWebSocketStatus.connected
              ? GatewayWebSocketStatus.disconnected
              : _status;
          _cleanup(nextStatus: statusAfterClose);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Greška pri spajanju na WebSocket: $e');
      _cleanup(nextStatus: GatewayWebSocketStatus.error);
    }
  }

  void _cleanup({required GatewayWebSocketStatus nextStatus}) {
    _subscription?.cancel();
    _subscription = null;

    final existingChannel = _channel;
    _channel = null;

    if (existingChannel != null) {
      try {
        existingChannel.sink.close();
      } catch (_) {}
    }

    _status = nextStatus;
  }

  Future<void> disconnect() async {
    _subscription?.cancel();
    _subscription = null;

    final existingChannel = _channel;
    _channel = null;

    if (existingChannel != null) {
      try {
        await existingChannel.sink.close();
      } catch (e) {
        print('Greška pri zatvaranju WebSocket kanala: $e');
      }
    }

    _status = GatewayWebSocketStatus.disconnected;
  }
}
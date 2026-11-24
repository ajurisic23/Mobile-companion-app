import 'package:flutter/foundation.dart';

import '../../gateway/models/can_port.dart';
import '../../gateway/models/gateway_info.dart';
import '../../gateway/services/gateway_websocket_service.dart';
import 'live_signal_store.dart';

class LiveCanController extends ChangeNotifier {
  LiveCanController({
    required this._webSocketService,
    required this._signalStore,
  });

  final GatewayWebSocketService _webSocketService;
  final LiveSignalStore _signalStore;

  bool get isConnected => _webSocketService.isConnected;

  GatewayWebSocketStatus get status => _webSocketService.status;

  Future<void> connect({
    required GatewayInfo gateway,
    required CanPort canPort,
  }) async {
    if (!canPort.enabled) return;

    await disconnect();

    try {
      await _webSocketService.connect(
        host: gateway.host,
        port: gateway.port,
        canPort: canPort.name,
        onMessage: (rawMessage) {
          _signalStore.applyRawMessage(rawMessage);
        },
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    await _webSocketService.disconnect();
    notifyListeners();
  }
}
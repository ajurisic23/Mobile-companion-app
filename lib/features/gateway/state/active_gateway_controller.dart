import 'package:flutter/foundation.dart';

import '../models/can_port.dart';
import '../models/gateway_info.dart';

class ActiveGatewayController extends ChangeNotifier {
  GatewayInfo? _gateway;
  CanPort? _port;

  GatewayInfo? get gateway => _gateway;
  CanPort? get port => _port;

  void selectGateway(GatewayInfo gateway) {
    if (_gateway == gateway) return;

    final sameAddress = _gateway?.hasSameAddressAs(gateway) ?? false;
    _gateway = gateway;
    if (!sameAddress) _port = null;

    notifyListeners();
  }

  void selectPort(CanPort port) {
    if (_gateway == null || _port == port) return;

    _port = port;
    notifyListeners();
  }

  void clear() {
    if (_gateway == null && _port == null) return;

    _gateway = null;
    _port = null;
    notifyListeners();
  }
}
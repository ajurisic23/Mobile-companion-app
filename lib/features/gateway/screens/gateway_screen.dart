
import 'package:flutter/material.dart';

import '../models/gateway_info.dart';
import '../services/gateway_connection_service.dart';
import 'connection_screen.dart';

class GatewayScreen extends StatefulWidget {
  const GatewayScreen({super.key});

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen> {
  final _connectionService = GatewayConnectionService();

  static const _sampleGateways = [
    GatewayInfo(
      name: 'Machine 1',
      host: '192.168.0.100',
      port: 80,
    ),
    GatewayInfo(
      name: 'Machine 2',
      host: '192.168.0.101',
      port: 80,
    ),
    GatewayInfo(
      name: 'Machine 3',
      host: '192.168.0.102',
      port: 80,
    ),
  ];

  Future<void> _simulateConnect() {
    return Future<void>.delayed(
      const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionScreen(
      onConnect: _connectionService.connect,
      onConnectSaved: (gateway) =>
          _connectionService.connect(
            gateway.host,
            gateway.port.toString(),
          ),
      onUseSimulated: _simulateConnect,
      savedGateways: _sampleGateways,
    );
  }
}

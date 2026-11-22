import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/gateway_info.dart';
import '../services/gateway_connection_service.dart';
import '../services/gateway_repository.dart';
import '../services/local_gateway_repository.dart';
import '../state/active_gateway_controller.dart';
import 'connection_screen.dart';

class GatewayScreen extends StatefulWidget {
  const GatewayScreen({
    super.key,
    this.repository = const LocalGatewayRepository(),
    this.connectionService,
  });

  final GatewayRepository repository;
  final GatewayConnectionService? connectionService;

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen> {
  late final GatewayConnectionService _connectionService;
  List<GatewayInfo> _savedGateways = const [];

  @override
  void initState() {
    super.initState();
    _connectionService = widget.connectionService ?? GatewayConnectionService();
    _loadSavedGateways();
  }

  Future<void> _loadSavedGateways() async {
    final gateways = await widget.repository.getAll();
    if (!mounted) return;
    setState(() => _savedGateways = gateways);
  }

  Future<void> _connect(String host, String port) async {
    final activeGateway = context.read<ActiveGatewayController>();

    await _connectionService.connect(host, port);

    final portNumber = port.isEmpty
        ? GatewayConnectionService.defaultPort
        : int.parse(port);
    final gateway = GatewayInfo(
      name: '$host:$portNumber',
      host: host,
      port: portNumber,
    );

    await _saveGateway(gateway);

    final saved = _savedGateways.firstWhere(
      gateway.hasSameAddressAs,
      orElse: () => gateway,
    );
    activeGateway.selectGateway(saved);
  }

  Future<void> _connectSaved(GatewayInfo gateway) async {
    final activeGateway = context.read<ActiveGatewayController>();

    await _connectionService.connect(gateway.host, gateway.port.toString());

    activeGateway.selectGateway(gateway);
  }

  Future<void> _deleteGateway(GatewayInfo gateway) async {
    try {
      await widget.repository.delete(gateway);
    } catch (error) {
      debugPrint('Deleting gateway failed: $error');
    }

    await _loadSavedGateways();
  }

  Future<void> _saveGateway(GatewayInfo gateway) async {
    if (_savedGateways.any(gateway.hasSameAddressAs)) return;

    try {
      await widget.repository.save(gateway);
    } catch (error) {
      debugPrint('Saving gateway failed: $error');
      return;
    }

    await _loadSavedGateways();
  }

  Future<void> _simulateConnect() {
    return Future<void>.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionScreen(
      onConnect: _connect,
      onConnectSaved: _connectSaved,
      onDeleteSaved: _deleteGateway,
      onUseSimulated: _simulateConnect,
      savedGateways: _savedGateways,
    );
  }
}
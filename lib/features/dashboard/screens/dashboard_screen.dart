
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/can_module_registry.g.dart';
import '../../can/state/live_can_controller.dart';
import '../../can/state/live_signal_store.dart';
import '../../gateway/services/can_ports_service.dart';
import '../../gateway/services/gateway_health_service.dart';
import '../../gateway/state/active_gateway_controller.dart';
import '../../gateway/widgets/can_port_selector.dart';
import '../../gateway/widgets/gateway_status_row.dart';

import '../services/live_can_signal_source.dart';
import 'dashboard_preview_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.canPortsService,
    this.gatewayHealthService,
  });

  final CanPortsService? canPortsService;
  final GatewayHealthService? gatewayHealthService;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final LiveCanSignalSource _signalSource;

  @override
  void initState() {
    super.initState();

    _signalSource = LiveCanSignalSource(
      context.read<LiveSignalStore>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeGateway = context.watch<ActiveGatewayController>();
    final gateway = activeGateway.gateway;
    final selectedPort = activeGateway.port;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Live Dashboard', style: textTheme.titleLarge),

            const SizedBox(height: 24),

            CanPortSelector(
              gateway: gateway,
              selectedPort: selectedPort,
              onSelected: activeGateway.selectPort,
              service: widget.canPortsService,
            ),

            if (gateway != null) ...[
              const SizedBox(height: 12),
              GatewayStatusRow(
                gateway: gateway,
                healthService: widget.gatewayHealthService,
              ),
            ],

            if (gateway != null && selectedPort != null)
              ElevatedButton(
                onPressed: () {
                  context.read<LiveCanController>().connect(
                    gateway: gateway,
                    canPort: selectedPort,
                  );
                },
                child: const Text('Start live CAN'),
              ),

            const SizedBox(height: 20),

            Expanded(
              child: DashboardPreviewScreen(
                signalSource: _signalSource,
                views: registeredCanViews,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../can/state/live_can_controller.dart';
import '../../can/state/live_signal_store.dart';
import '../../gateway/services/can_ports_service.dart';
import '../../gateway/services/gateway_health_service.dart';
import '../../gateway/state/active_gateway_controller.dart';
import '../../gateway/widgets/can_port_selector.dart';
import '../../gateway/widgets/gateway_status_row.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.canPortsService,
    this.gatewayHealthService,
  });

  final CanPortsService? canPortsService;
  final GatewayHealthService? gatewayHealthService;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeGateway = context.watch<ActiveGatewayController>();
    final gateway = activeGateway.gateway;
    final selectedPort = activeGateway.port;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          children: [
            Text('Live Dashboard', style: textTheme.titleLarge),
            const SizedBox(height: 24),
            CanPortSelector(
              gateway: gateway,
              selectedPort: activeGateway.port,
              onSelected: activeGateway.selectPort,
              service: canPortsService,
            ),
            if (gateway != null) ...[
              const SizedBox(height: 12),
              GatewayStatusRow(
                gateway: gateway,
                healthService: gatewayHealthService,
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

            const Text(
              'Received CAN signals:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Consumer<LiveSignalStore>(
              builder: (context, store, child) {
                final signals = store.entriesByTag.values.toList();

                if (signals.isEmpty) {
                  return const Text('Waiting for signals...');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: signals.map((entry) {
                    return Text(
                      '${entry.tag}: ${entry.value} ${entry.unit ?? ''}',
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../gateway/services/can_ports_service.dart';
import '../../gateway/state/active_gateway_controller.dart';
import '../../gateway/widgets/can_port_selector.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.canPortsService});

  final CanPortsService? canPortsService;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeGateway = context.watch<ActiveGatewayController>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          children: [
            Text('Live Dashboard', style: textTheme.titleLarge),
            const SizedBox(height: 24),
            CanPortSelector(
              gateway: activeGateway.gateway,
              selectedPort: activeGateway.port,
              onSelected: activeGateway.selectPort,
              service: canPortsService,
            ),
          ],
        ),
      ),
    );
  }
}
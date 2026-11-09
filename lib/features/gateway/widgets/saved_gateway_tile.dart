import 'package:flutter/material.dart';

import '../models/gateway_info.dart';

class SavedGatewayTile extends StatelessWidget {
  const SavedGatewayTile({
    super.key,
    required this.gateway,
    this.onConnect,
  });

  final GatewayInfo gateway;
  
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(gateway.name),
      subtitle: Text(gateway.address),
      trailing: IconButton.filledTonal(
        tooltip: 'Connect',
        icon: const Icon(Icons.link),
        onPressed: onConnect,
      ),
    );
  }
}
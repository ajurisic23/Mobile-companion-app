import 'package:flutter/material.dart';

import '../models/gateway_info.dart';

class SavedGatewayTile extends StatelessWidget {
  const SavedGatewayTile({
    super.key,
    required this.gateway,
    this.onConnect,
    this.onDelete,
  });

  final GatewayInfo gateway;

  final VoidCallback? onConnect;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showAddress = gateway.name != gateway.address;

    return ListTile(
      onTap: onConnect,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: scheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(gateway.name),
      subtitle: showAddress ? Text(gateway.address) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
          IconButton.filledTonal(
            tooltip: 'Connect',
            icon: const Icon(Icons.link),
            onPressed: onConnect,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../services/gateway_health_service.dart';

class GatewayHealthStatusWidget extends StatelessWidget {
  final GatewayHealthStatus? status;
  final bool isChecking;

  const GatewayHealthStatusWidget({
    super.key,
    required this.status,
    this.isChecking = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isChecking && status == null) {
      return const SizedBox.shrink();
    }

    final String message;
    final IconData icon;
    final Color color;

    if (isChecking) {
      message = 'Checking gateway...';
      icon = Icons.hourglass_empty;
      color = Colors.grey;
    } else {
      switch (status!) {
        case GatewayHealthStatus.available:
          message = 'Gateway available';
          icon = Icons.check_circle_outline;
          color = Colors.green;

        case GatewayHealthStatus.unavailable:
          message = 'Gateway unavailable';
          icon = Icons.error_outline;
          color = Colors.red;

        case GatewayHealthStatus.timeout:
          message = 'Connection timed out';
          icon = Icons.access_time;
          color = Colors.red;

        case GatewayHealthStatus.networkError:
          message = 'Network error';
          icon = Icons.wifi_off;
          color = Colors.red;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

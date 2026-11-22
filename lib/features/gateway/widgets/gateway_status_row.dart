import 'package:flutter/material.dart';

import '../models/gateway_info.dart';
import '../services/gateway_health_service.dart';

class GatewayStatusRow extends StatefulWidget {
  const GatewayStatusRow({
    super.key,
    required this.gateway,
    this.healthService,
  });

  final GatewayInfo gateway;
  final GatewayHealthService? healthService;

  @override
  State<GatewayStatusRow> createState() => _GatewayStatusRowState();
}

class _GatewayStatusRowState extends State<GatewayStatusRow> {
  late final GatewayHealthService _healthService;
  GatewayHealthStatus? _status;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _healthService = widget.healthService ?? GatewayHealthService();
    _check();
  }

  @override
  void didUpdateWidget(GatewayStatusRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.gateway.hasSameAddressAs(widget.gateway)) return;

    _status = null;
    _check();
  }

  Future<void> _check() async {
    final gateway = widget.gateway;
    final requestId = ++_requestId;

    GatewayHealthStatus status;
    try {
      status = await _healthService.checkHealth(
        address: gateway.host,
        port: gateway.port,
      );
    } catch (_) {
      status = GatewayHealthStatus.unavailable;
    }

    if (!mounted || requestId != _requestId) return;
    setState(() => _status = status);
  }

  String _label(GatewayHealthStatus status) {
    return switch (status) {
      GatewayHealthStatus.available => 'Active',
      GatewayHealthStatus.unavailable => 'Unavailable',
      GatewayHealthStatus.timeout => 'Not responding',
      GatewayHealthStatus.networkError => 'Unreachable',
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final status = _status;

    final Widget indicator;
    if (status == null) {
      indicator = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 6),
          Text('Checking...', style: textTheme.bodySmall),
        ],
      );
    } else {
      final isActive = status == GatewayHealthStatus.available;
      final color = isActive ? scheme.primary : scheme.error;
      indicator = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.error_outline,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            _label(status),
            style: textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.gateway.host, style: textTheme.bodyMedium),
        indicator,
      ],
    );
  }
}
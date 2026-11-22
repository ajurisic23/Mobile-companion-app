import 'package:flutter/material.dart';

import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/inline_error.dart';
import '../models/can_port.dart';
import '../models/gateway_info.dart';
import '../services/can_ports_service.dart';

class CanPortSelector extends StatefulWidget {
  const CanPortSelector({
    super.key,
    required this.gateway,
    required this.selectedPort,
    required this.onSelected,
    this.service,
  });

  final GatewayInfo? gateway;
  final CanPort? selectedPort;
  final ValueChanged<CanPort> onSelected;
  final CanPortsService? service;

  @override
  State<CanPortSelector> createState() => _CanPortSelectorState();
}

class _CanPortSelectorState extends State<CanPortSelector> {
  late final CanPortsService _service;
  List<CanPort>? _ports;
  String? _errorMessage;
  bool _isLoading = false;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? CanPortsService();
    if (widget.gateway != null) {
      _isLoading = true;
      _fetch();
    }
  }

  @override
  void didUpdateWidget(CanPortSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previous = oldWidget.gateway;
    final current = widget.gateway;
    final sameGateway = previous != null &&
        current != null &&
        previous.hasSameAddressAs(current);
    if (sameGateway || (previous == null && current == null)) return;

    _requestId++;
    _ports = null;
    _errorMessage = null;
    _isLoading = current != null;
    if (current != null) _fetch();
  }

  void _retry() {
    setState(() {
      _ports = null;
      _errorMessage = null;
      _isLoading = true;
    });
    _fetch();
  }

  Future<void> _fetch() async {
    final gateway = widget.gateway;
    if (gateway == null) return;

    final requestId = ++_requestId;
    List<CanPort>? ports;
    String? errorMessage;

    try {
      ports = await _service.fetchPorts(host: gateway.host, port: gateway.port);
    } on CanPortsException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Could not load the CAN ports.';
    }

    if (!mounted || requestId != _requestId) return;
    setState(() {
      _isLoading = false;
      _ports = ports;
      _errorMessage = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final ports = _ports;
    final errorMessage = _errorMessage;

    if (widget.gateway == null) {
      return Text(
        'Connect to a gateway to see its CAN ports.',
        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    if (_isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text('Loading CAN ports...', style: textTheme.bodyMedium),
        ],
      );
    }

    if (errorMessage != null || ports == null || ports.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InlineError(
            message: errorMessage ?? 'This gateway has no CAN ports available.',
          ),
          const SizedBox(height: 8),
          SecondaryButton(label: 'Try again', onPressed: _retry),
        ],
      );
    }

    final selected = ports.contains(widget.selectedPort)
        ? widget.selectedPort
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('CAN port', style: textTheme.bodySmall),
            Text(
              ports.length == 1 ? '1 port' : '${ports.length} ports',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CanPort>(
              isExpanded: true,
              value: selected,
              hint: const Text('Select a CAN port'),
              items: [
                for (final port in ports)
                  DropdownMenuItem<CanPort>(
                    value: port,
                    enabled: port.enabled,
                    child: Text(
                      port.enabled ? port.label : '${port.label} (disabled)',
                    ),
                  ),
              ],
              onChanged: (port) {
                if (port != null) widget.onSelected(port);
              },
            ),
          ),
        ),
      ],
    );
  }
}
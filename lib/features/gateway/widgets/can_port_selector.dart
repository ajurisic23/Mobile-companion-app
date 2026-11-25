import 'package:flutter/material.dart';

import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../core/widgets/feedback/inline_error.dart';
import '../../../l10n/app_localizations.dart';

import '../localization/gateway_failure_localization.dart';
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
  State<CanPortSelector> createState() =>
      _CanPortSelectorState();
}

class _CanPortSelectorState extends State<CanPortSelector> {
  late final CanPortsService _service;

  List<CanPort>? _ports;
  CanPortsException? _failure;

  bool _hasUnknownError = false;
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

    if (sameGateway ||
        (previous == null && current == null)) {
      return;
    }

    _requestId++;
    _ports = null;
    _failure = null;
    _hasUnknownError = false;
    _isLoading = current != null;

    if (current != null) {
      _fetch();
    }
  }

  void _retry() {
    setState(() {
      _ports = null;
      _failure = null;
      _hasUnknownError = false;
      _isLoading = true;
    });

    _fetch();
  }

  Future<void> _fetch() async {
    final gateway = widget.gateway;

    if (gateway == null) return;

    final requestId = ++_requestId;

    List<CanPort>? ports;
    CanPortsException? failure;
    bool hasUnknownError = false;

    try {
      ports = await _service.fetchPorts(
        host: gateway.host,
        port: gateway.port,
      );
    } on CanPortsException catch (error) {
      failure = error;
    } catch (_) {
      hasUnknownError = true;
    }

    if (!mounted || requestId != _requestId) return;

    setState(() {
      _isLoading = false;
      _ports = ports;
      _failure = failure;
      _hasUnknownError = hasUnknownError;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final ports = _ports;

    final errorMessage = _hasUnknownError
        ? l10n.canPortsUnknown
        : _failure?.localizedMessage(l10n);

    if (widget.gateway == null) {
      return Text(
        l10n.connectToSeePorts,
        style: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );
    }

    if (_isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.loadingCanPorts,
            style: textTheme.bodyMedium,
          ),
        ],
      );
    }

    if (errorMessage != null ||
        ports == null ||
        ports.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InlineError(
            message: errorMessage ?? l10n.noCanPorts,
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: l10n.tryAgain,
            onPressed: _retry,
          ),
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
            Text(
              l10n.canPort,
              style: textTheme.bodySmall,
            ),
            Text(
              l10n.canPortCount(ports.length),
              style: textTheme.bodySmall,
            ),
          ],
        ),

        const SizedBox(height: 8),

        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<CanPort>(
              isExpanded: true,
              value: selected,
              hint: Text(l10n.selectCanPort),
              items: [
                for (final port in ports)
                  DropdownMenuItem<CanPort>(
                    value: port,
                    enabled: port.enabled,
                    child: Text(
                      port.enabled
                          ? port.label
                          : '${port.label} (${l10n.disabled})',
                    ),
                  ),
              ],
              onChanged: (port) {
                if (port != null) {
                  widget.onSelected(port);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
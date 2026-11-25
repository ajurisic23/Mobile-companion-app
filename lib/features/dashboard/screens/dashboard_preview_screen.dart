import 'dart:async';

import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

import '../interfaces/can_signal_source.dart';

class DashboardPreviewScreen extends StatefulWidget {
  const DashboardPreviewScreen({
    super.key,
    required this.signalSource,
    required this.views,
    this.hasGateway = true,
    this.hasSelectedPort = true,
    this.isConnecting = false,
    this.connectionFailed = false,
  });

  final CanSignalSource signalSource;
  final List<CanSignalView> views;

  final bool hasGateway;
  final bool hasSelectedPort;
  final bool isConnecting;
  final bool connectionFailed;

  @override
  State<DashboardPreviewScreen> createState() =>
      _DashboardPreviewScreenState();
}

class _DashboardPreviewScreenState
    extends State<DashboardPreviewScreen> {
  String? _selectedViewId;

  List<SignalDisplayData> _signals = [];

  StreamSubscription<List<SignalDisplayData>>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = widget.signalSource.signals.listen((signals) {
      if (!mounted) return;

      setState(() {
        _signals = signals;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Widget _buildStatus({
    required IconData icon,
    required String title,
    required String description,
    bool isLoading = false,
    bool isError = false,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              )
            else
              Icon(
                icon,
                size: 48,
                color: isError
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),

            const SizedBox(height: 20),

            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasGateway) {
      return _buildStatus(
        icon: Icons.router_outlined,
        title: 'Select a gateway',
        description:
        'Connect to a gateway to access CAN ports.',
      );
    }

    if (!widget.hasSelectedPort) {
      return _buildStatus(
        icon: Icons.cable,
        title: 'Select a CAN port',
        description:
        'Choose a CAN port to start receiving live data.',
      );
    }

    if (widget.isConnecting) {
      return _buildStatus(
        icon: Icons.sync,
        title: 'Connecting...',
        description:
        'Establishing a connection to the CAN port.',
        isLoading: true,
      );
    }

    if (widget.connectionFailed) {
      return _buildStatus(
        icon: Icons.error_outline,
        title: 'Connection failed',
        description:
        'Unable to connect to the selected CAN port.',
        isError: true,
      );
    }

    if (_signals.isEmpty) {
      return _buildStatus(
        icon: Icons.sensors,
        title: 'Waiting for CAN signals...',
        description:
        'Waiting for incoming live data.',
        isLoading: true,
      );
    }

    if (widget.views.isEmpty) {
      return _buildStatus(
        icon: Icons.extension_off_outlined,
        title: 'No signal display modules available.',
        description:
        'Add a CAN visualization module to display signals.',
      );
    }

    final selectedId =
    _selectedViewId != null &&
        widget.views.any(
              (view) => view.id == _selectedViewId,
        )
        ? _selectedViewId!
        : widget.views.first.id;

    final selectedView = widget.views.firstWhere(
          (view) => view.id == selectedId,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'CAN signals:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: widget.views.map((view) {
                  return ButtonSegment<String>(
                    value: view.id,
                    icon: Icon(view.icon),
                    tooltip: view.label,
                  );
                }).toList(),
                selected: {selectedId},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedViewId = selection.first;
                  });
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: selectedView.buildView(_signals),
        ),
      ],
    );
  }
}
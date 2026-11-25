
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

import '../interfaces/can_signal_source.dart';

class DashboardPreviewScreen extends StatefulWidget {
  const DashboardPreviewScreen({
    super.key,
    required this.signalSource,
    required this.views,
  });

  final CanSignalSource signalSource;
  final List<CanSignalView> views;

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

  @override
  Widget build(BuildContext context) {
    if (_signals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sensors_off_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No CAN signals available',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Signals will be displayed when data becomes available.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.views.isEmpty) {
      return const Center(
        child: Text('No signal display modules available.'),
      );
    }

    final selectedId = _selectedViewId != null &&
        widget.views.any((view) => view.id == _selectedViewId)
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

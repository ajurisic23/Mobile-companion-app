
import 'dart:async';


import 'package:flutter/material.dart';

import 'package:can_core/can_core.dart';
import '../interfaces/can_signal_source.dart';
import '../widgets/can_signal_grid.dart';
import '../widgets/can_signal_list.dart';

class DashboardPreviewScreen extends StatefulWidget {
  const DashboardPreviewScreen({
    super.key,
    required this.signalSource,
  });

  final CanSignalSource signalSource;

  @override
  State<DashboardPreviewScreen> createState() =>
      _DashboardPreviewScreenState();
}

class _DashboardPreviewScreenState extends State<DashboardPreviewScreen> {

  bool _showGrid = true;

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
                'Nema dostupnih CAN signala',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Signali će se prikazati kada podaci postanu dostupni.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }


    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('Kartice'),
                icon: Icon(Icons.grid_view),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('Lista'),
                icon: Icon(Icons.view_list),
              ),
            ],
            selected: {_showGrid},
            onSelectionChanged: (selection) {
              setState(() {
                _showGrid = selection.first;
              });
            },
          ),
        ),
        Expanded(
          child: _showGrid
              ? CanSignalGrid(signals: _signals)
              : CanSignalList(signals: _signals),
        ),
      ],
    );

  }

}

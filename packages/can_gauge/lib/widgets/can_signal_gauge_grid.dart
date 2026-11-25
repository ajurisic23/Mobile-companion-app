import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

import 'can_signal_gauge.dart';

class CanSignalGaugeGrid extends StatelessWidget {
  const CanSignalGaugeGrid({
    super.key,
    required this.signals,
  });

  final List<SignalDisplayData> signals;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 220,
      ),
      itemCount: signals.length,
      itemBuilder: (context, index) {
        return CanSignalGauge(
          signal: signals[index],
        );
      },
    );
  }
}
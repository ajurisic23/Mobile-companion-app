
import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

import 'can_signal_card.dart';

class CanSignalGrid extends StatelessWidget {
  const CanSignalGrid({
    super.key,
    required this.signals,
  });

  final List<SignalDisplayData> signals;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: signals.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 170,
      ),
      itemBuilder: (context, index) {
        final signal = signals[index];

        return CanSignalCard(
          key: ValueKey(signal.tag),
          signal: signal,
        );
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

class CanSignalList extends StatelessWidget {
  const CanSignalList({
    super.key,
    required this.signals,
  });

  final List<SignalDisplayData> signals;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: signals.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final signal = signals[index];

        final hasUnit =
            signal.unit != null &&
                signal.unit!.trim().isNotEmpty;

        return Card(
          key: ValueKey(signal.tag),
          child: ListTile(
            title: Text(
              signal.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              hasUnit
                  ? '${signal.value} ${signal.unit}'
                  : signal.value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}

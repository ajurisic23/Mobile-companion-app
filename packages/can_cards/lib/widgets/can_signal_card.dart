
import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

class CanSignalCard extends StatelessWidget {
  const CanSignalCard({
    super.key,
    required this.signal,
  });

  final SignalDisplayData signal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasUnit =
        signal.unit != null && signal.unit!.trim().isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              signal.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    signal.value,
                    maxLines: 1,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (hasUnit)
                  Text(
                    signal.unit!,
                    style: theme.textTheme.bodyMedium,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

import '../utils/gauge_range_resolver.dart';

class CanSignalGauge extends StatelessWidget {
  const CanSignalGauge({
    super.key,
    required this.signal,
  });

  final SignalDisplayData signal;

  String _formatValue(String rawValue) {
    final value = double.tryParse(rawValue);

    if (value == null || !value.isFinite) {
      return rawValue;
    }

    return _formatNumber(value);
  }

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _fallbackLabel() {
    final unit = signal.unit?.trim().toLowerCase();

    switch (unit) {
      case 'h':
      case 'm':
      case 'km':
      case 'l':
        return 'Numeric value';

      default:
        if (unit == null || unit.isEmpty) {
          return 'Unitless value';
        }

        return 'Numeric value';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final range = GaugeRangeResolver.resolve(signal);
    final value = double.tryParse(signal.value);
    final formattedValue = _formatValue(signal.value);
    final hasUnit = signal.unit?.trim().isNotEmpty ?? false;

    final progress =
    range != null && value != null && value.isFinite
        ? range.normalize(value)
        : null;

    final outsideRange =
        range != null &&
            value != null &&
            value.isFinite &&
            (value < range.min || value > range.max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: signal.name,
              child: Text(
                signal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (progress != null) ...[
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 8,
                        color: theme
                            .colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.all(
                      progress != null ? 14 : 4,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (progress == null) ...[
                          Icon(
                            Icons.numbers,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                        ],
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            formattedValue,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (hasUnit)
                          Text(
                            signal.unit!,
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress != null && range != null
                  ? '${_formatNumber(range.min)} – '
                  '${_formatNumber(range.max)}'
                  '${hasUnit ? ' ${signal.unit}' : ''}'
                  : _fallbackLabel(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (outsideRange)
              Text(
                'Outside display range',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
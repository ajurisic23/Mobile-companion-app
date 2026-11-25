import 'package:flutter/material.dart';

import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/secondary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../models/gateway_info.dart';

class DeleteGatewayDialog extends StatelessWidget {
  const DeleteGatewayDialog({
    super.key,
    required this.gateway,
  });

  final GatewayInfo gateway;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: scheme.error,
            ),

            const SizedBox(height: 16),

            Text(
              l10n.deleteGateway,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              l10n.deleteGatewayConfirmation(gateway.address),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            PrimaryButton(
              label: l10n.delete,
              onPressed: () => Navigator.of(context).pop(true),
            ),

            const SizedBox(height: 8),

            SecondaryButton(
              label: l10n.cancel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> confirmDeleteGateway(
    BuildContext context,
    GatewayInfo gateway,
    ) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => DeleteGatewayDialog(gateway: gateway),
  );

  return confirmed ?? false;
}
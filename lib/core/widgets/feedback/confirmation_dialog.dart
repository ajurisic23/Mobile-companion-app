import 'package:flutter/material.dart';
import 'package:mobile_companion_app/core/widgets/buttons/primary_button.dart';
import 'package:mobile_companion_app/core/widgets/buttons/secondary_button.dart';

enum DialogType { info, warning, error }

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.type,
    required this.title,
    required this.description,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
  });

  final DialogType type;
  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  (IconData, Color) _resolveIconAndColor(ColorScheme scheme) {
    return switch (type) {
      DialogType.info => (Icons.info_outline_rounded, scheme.primary),
      DialogType.warning => (Icons.warning_amber_rounded, scheme.tertiary),
      DialogType.error => (Icons.error_outline_rounded, scheme.error),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (iconData, iconColor) = _resolveIconAndColor(scheme);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(iconData, size: 48, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: "Save", onPressed: onConfirm ?? () => Navigator.of(context).pop()),
            const SizedBox(height: 8),
            SecondaryButton(label: "Cancel", onPressed: onCancel ?? () => Navigator.of(context).pop())
          ],
        ),
      ),
    );
  }
}
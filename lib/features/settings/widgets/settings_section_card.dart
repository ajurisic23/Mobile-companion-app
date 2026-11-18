import 'package:flutter/material.dart';
import 'package:mobile_companion_app/features/settings/models/gateway_setting_section.dart';

class SettingsSectionCard extends StatelessWidget {
  final GatewaySettingSection section;

  const SettingsSectionCard({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: section.initiallyExpanded,
        leading: Icon(section.icon, color: scheme.primary),
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(section.subtitle),
        children: section.settings.map((item) {
          return ListTile(
            title: Text(item.label),
            trailing: Text(
              item.value,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          );
        }).toList(),
      ),
    );
  }
}
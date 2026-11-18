import 'package:flutter/material.dart';
import 'package:mobile_companion_app/features/settings/mock_data.dart';

import '../models/gateway_setting_section.dart';
import '../widgets/settings_section_card.dart';

class SettingsScreen extends StatelessWidget {
  final List<GatewaySettingSection>? sections;

  const SettingsScreen({
    super.key,
    this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // privremeno
    const String connectionInterface = 'CAN0';
    const String ipAddress = '192.168.0.100';

    final displaySections = sections ?? mockGatewaySections;

    return ListView(
      children: [
        Text('Configure the gateway', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '$connectionInterface\n$ipAddress',
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ...displaySections.map((section) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SettingsSectionCard(section: section),
          );
        }),
      ],
    );
  }
}
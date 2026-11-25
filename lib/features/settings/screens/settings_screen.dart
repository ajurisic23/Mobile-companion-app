import 'package:flutter/material.dart';
import 'package:mobile_companion_app/core/widgets/buttons/primary_button.dart';
import 'package:mobile_companion_app/core/widgets/feedback/confirmation_dialog.dart';
import 'package:mobile_companion_app/features/settings/mock_data.dart';
import 'package:provider/provider.dart';

import '../../multilanguage/date_format/locale_controller.dart';
import '../../multilanguage/date_format/locale_formatter.dart';
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
    final currentCode = context.watch<LocaleController>().locale.languageCode;
    final formattedTemp = LocaleFormatter.formatTemperature(context, 85.5);
    final sampleDateTime = DateTime(2026, 11, 25, 14, 30);
    final formattedDate = LocaleFormatter.formatDate(context, sampleDateTime);
    final formattedTime = LocaleFormatter.formatTime(context, sampleDateTime)
        .replaceAll('\u202f', ' ');

    // privremeno
    const String connectionInterface = 'CAN0';
    const String ipAddress = '192.168.0.100';

    final displaySections = sections ?? mockGatewaySections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Language', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'en',
                            label: Text('English (EN)'),
                          ),
                          ButtonSegment<String>(
                            value: 'de',
                            label: Text('Deutsch (DE)'),
                          ),
                        ],
                        selected: {currentCode},
                        onSelectionChanged: (selection) {
                          context
                              .read<LocaleController>()
                              .setLocale(Locale(selection.first));
                        },
                      ),
                      const SizedBox(height: 12),
                      Text('Last check: $formattedDate · $formattedTime'),
                      const SizedBox(height: 6),
                      Text('Temperature: $formattedTemp')
                    ],
                  ),
                ),
              ),
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
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: "Save changes",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ConfirmationDialog(
                type: DialogType.warning,
                title: "Confirm Gateway Changes",
                description:
                'Are you sure you want to save these changes? Modifying gateway settings may temporarily disrupt communication.',
              ),
            );
          },
        ),
      ],
    );
  }
}
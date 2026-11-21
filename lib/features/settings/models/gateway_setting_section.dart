import 'package:flutter/material.dart';
import 'package:mobile_companion_app/features/settings/models/gateway_setting_item.dart';

class GatewaySettingSection {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<GatewaySettingItem> settings;
  final bool initiallyExpanded;

  const GatewaySettingSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.settings,
    this.initiallyExpanded = false,
  });
}
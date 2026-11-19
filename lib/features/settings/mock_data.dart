import 'package:flutter/material.dart';
import 'package:mobile_companion_app/features/settings/models/gateway_setting_section.dart';
import 'package:mobile_companion_app/features/settings/models/gateway_setting_item.dart';

final List<GatewaySettingSection> mockGatewaySections = [
  const GatewaySettingSection(
    title: 'Network & Connectivity',
    subtitle: 'IP address, Wi-Fi and port configuration',
    icon: Icons.wifi_rounded,
    initiallyExpanded: false,
    settings: [
      GatewaySettingItem(label: 'IP Address', value: '192.168.0.100'),
      GatewaySettingItem(label: 'Subnet Mask', value: '255.255.255.0'),
      GatewaySettingItem(label: 'Port', value: '8883'),
    ],
  ),
  const GatewaySettingSection(
    title: 'MQTT Broker',
    subtitle: 'Broker URL, client ID and authentication',
    icon: Icons.cloud_outlined,
    settings: [
      GatewaySettingItem(label: 'Broker URL', value: 'mqtt.factory.local'),
      GatewaySettingItem(label: 'Client ID', value: 'Gateway_CAN_01'),
      GatewaySettingItem(label: 'Keep Alive', value: '60s'),
    ],
  ),
  const GatewaySettingSection(
    title: 'GNSS & Location',
    subtitle: 'GPS update interval and satellite settings',
    icon: Icons.location_on_outlined,
    settings: [
      GatewaySettingItem(label: 'Update Interval', value: '5s'),
      GatewaySettingItem(label: 'High Precision', value: 'Enabled'),
    ],
  ),
];
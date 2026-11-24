
import 'package:flutter/material.dart';

enum NavigationTab {
  gateway(
    title: 'Gateway',
    icon: Icons.cable,
  ),
  dashboard(
    title: 'Dashboard',
    icon: Icons.dashboard_outlined,
  ),
  settings(
    title: 'Settings',
    icon: Icons.settings_outlined,
  ),
  alerts(
    title: 'Alerts',
    icon: Icons.warning_amber_outlined,
  );

  const NavigationTab({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;
}

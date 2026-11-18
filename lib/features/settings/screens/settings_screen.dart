import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  // Privremene varijable – kasnije će ovdje dolaziti podaci iz servisa kada se korisnik spoji
  final String _connectionInterface = 'CAN0';
  final String _ipAddress = '192.168.0.100';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      children: [
        Text('Configure the gateway', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '$_connectionInterface\n$_ipAddress',
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),        const SizedBox(height: 24),

      ],
    );
  }
}
import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const MainLayout({
    super.key,
    required this.title,
    this.icon,
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        centerTitle: false,
        titleSpacing: 20,
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24),
              const SizedBox(width: 12),
            ],
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.cable), label: 'Gateway'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          NavigationDestination(icon: Icon(Icons.warning_amber_outlined), label: 'Alerts'),
        ],
      ),
    );
  }
}
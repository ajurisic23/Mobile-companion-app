
import 'package:flutter/material.dart';
import 'navigation_tab.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const MainLayout({
    super.key,
    required this.title,
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
        Theme.of(context).colorScheme.surfaceContainerLow,
        centerTitle: false,
        titleSpacing: 20,
        title: Row(
          children: [
            Icon(
              NavigationTab.values[currentIndex].icon,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      body: child,

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabSelected,
        destinations: NavigationTab.values.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            label: tab.title,
          );
        }).toList(),
      ),
    );
  }
}

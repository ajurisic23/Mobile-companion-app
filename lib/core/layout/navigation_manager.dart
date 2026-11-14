import 'package:flutter/material.dart';
import 'package:mobile_companion_app/app/main_navigation.dart';
import 'package:mobile_companion_app/features/settings/settings_screen.dart';
import 'main_layout.dart';

class NavigationManager extends StatefulWidget {
  const NavigationManager({super.key});

  @override
  State<NavigationManager> createState() => _NavigationManagerState();
}

class _NavigationManagerState extends State<NavigationManager> {
  int _currentIndex = 0;
  final List<int> _navigationHistory = [];

  final List<String> _titles = ['Gateway', 'Dashboard', 'Settings', 'Alerts'];

  @override
  Widget build(BuildContext context) {
    // Ovdje se samo pozivaju gotovi ekrani iz pojedinih feature-a
    final List<Widget> screens = [
      const MainNavigation(),
      const Center(child: Text('Dashboard')),
      const SettingsScreen(),
      const Center(child: Text('Alerts Ekran')),
    ];

    return PopScope(
      canPop: _navigationHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _navigationHistory.isNotEmpty) {
          setState(() {
            _currentIndex = _navigationHistory.removeLast();
          });
        }
      },
      child: MainLayout(
        title: _titles[_currentIndex],
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          if (index == _currentIndex) return;
          setState(() {
            _navigationHistory.add(_currentIndex);
            _currentIndex = index;
          });
        },
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
    );
  }
}
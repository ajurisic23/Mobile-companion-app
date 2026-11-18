
import 'package:flutter/material.dart';
import 'package:mobile_companion_app/features/settings/settings_screen.dart';

import 'main_layout.dart';
import 'navigation_tab.dart';
import 'screen_placeholder.dart';

import '../features/gateway/screens/gateway_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<int> _navigationHistory = [];

  Widget _buildScreen(NavigationTab tab) {
    return switch (tab) {
      NavigationTab.gateway => const GatewayScreen(),
      NavigationTab.settings => const SettingsScreen(),
      _ => ScreenPlaceholder(title: tab.title),
    };
  }

  void _selectScreen(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _navigationHistory.add(_selectedIndex);
      _selectedIndex = index;
    });
  }

  void _goBack() {
    if (_navigationHistory.isEmpty) return;

    setState(() {
      _selectedIndex = _navigationHistory.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _navigationHistory.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goBack();
        }
      },
      child: MainLayout(
        title: NavigationTab.values[_selectedIndex].title,
        currentIndex: _selectedIndex,
        onTabSelected: _selectScreen,
        child: IndexedStack(
          index: _selectedIndex,
          children: NavigationTab.values
              .map(_buildScreen)
              .toList(),
        ),
      ),
    );
  }
}

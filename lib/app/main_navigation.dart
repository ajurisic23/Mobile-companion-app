
import 'package:flutter/material.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<int> _navigationHistory = [];

  final List<String> _screenTitles = [
    'Gateway',
    'Dashboard',
    'Settings',
    'Alerts',
  ];

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
      child: Scaffold(

        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          centerTitle: false,
          titleSpacing: 20,
          title: Row(
            children: [
              Icon(
                [
                  Icons.cable,
                  Icons.dashboard_outlined,
                  Icons.settings_outlined,
                  Icons.warning_amber_outlined,
                ][_selectedIndex],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _screenTitles[_selectedIndex],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        body: Center(
          child: Text(
            _screenTitles[_selectedIndex],
            style: const TextStyle(fontSize: 24),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectScreen,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.cable),
              label: 'Gateway',
            ),
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
            NavigationDestination(
              icon: Icon(Icons.warning_amber_outlined),
              label: 'Alerts',
            ),
          ],
        ),
      ),
    );
  }
}

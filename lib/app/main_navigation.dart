
import 'package:flutter/material.dart';
import 'screen_placeholder.dart';
import 'navigation_tab.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<int> _navigationHistory = [];


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
                NavigationTab.values[_selectedIndex].icon,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                NavigationTab.values[_selectedIndex].title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        body: IndexedStack(
          index: _selectedIndex,
          children: NavigationTab.values.map((tab) {
            return ScreenPlaceholder(title: tab.title);
          }).toList(),
        ),

        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectScreen,
          destinations: NavigationTab.values.map((tab) {
            return NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.title,
            );
          }).toList(),
        ),

      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'screen_placeholder.dart';
import 'navigation_tab.dart';
import '../features/gateway/models/gateway_info.dart';
import '../features/gateway/screens/connection_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<int> _navigationHistory = [];

  // Privremeno: simulacija i probni podaci da se vidi cijeli ekran.
  // TODO: zamijeniti pravim servisom i spremljenim gatewayima.
  static const _sampleGateways = [
    GatewayInfo(name: 'Machine 1', host: '192.168.0.100', port: 80),
    GatewayInfo(name: 'Machine 2', host: '192.168.0.101', port: 80),
    GatewayInfo(name: 'Machine 3', host: '192.168.0.102', port: 80),
  ];

  Future<void> _simulateConnect() =>
      Future<void>.delayed(const Duration(seconds: 2));

  Widget _buildScreen(NavigationTab tab) => switch (tab) {
    NavigationTab.gateway => ConnectionScreen(
      onConnect: (host, port) => _simulateConnect(),
      onConnectSaved: (gateway) => _simulateConnect(),
      onUseSimulated: _simulateConnect,
      savedGateways: _sampleGateways,
    ),
    _ => ScreenPlaceholder(title: tab.title),
  };


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
          children: NavigationTab.values.map(_buildScreen).toList(),
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

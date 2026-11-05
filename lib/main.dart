
import 'package:flutter/material.dart';
import 'app/main_navigation.dart';

void main() {
  runApp(const MobileCompanionApp());
}

class MobileCompanionApp extends StatelessWidget {
  const MobileCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Companion App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

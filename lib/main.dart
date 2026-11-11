
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_companion_app/core/layout/navigation_manager.dart';
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
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const MainNavigation(),
    );
  }
}

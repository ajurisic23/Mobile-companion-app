import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app/main_navigation.dart';
import 'features/gateway/state/active_gateway_controller.dart';

void main() {
  runApp(const MobileCompanionApp());
}

class MobileCompanionApp extends StatelessWidget {
  const MobileCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActiveGatewayController(),
      child: MaterialApp(
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
      ),
    );
  }
}
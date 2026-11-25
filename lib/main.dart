import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app/main_navigation.dart';
import 'features/can/state/live_can_controller.dart';
import 'features/can/state/live_signal_store.dart';
import 'features/gateway/services/gateway_websocket_service.dart';
import 'features/gateway/state/active_gateway_controller.dart';

void main() {
  runApp(const MobileCompanionApp());
}

class MobileCompanionApp extends StatelessWidget {
  const MobileCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ActiveGatewayController(),
        ),

        Provider(
          create: (_) => GatewayWebSocketService(),
          dispose: (_, service) => service.disconnect(),
        ),

        ChangeNotifierProvider(
          create: (_) => LiveSignalStore(),
        ),

        ChangeNotifierProxyProvider2<
            GatewayWebSocketService,
            LiveSignalStore,
            LiveCanController>(
          create: (context) => LiveCanController(
            webSocketService: context.read<GatewayWebSocketService>(),
            signalStore: context.read<LiveSignalStore>(),
          ),
          update: (_, webSocketService, signalStore, controller) =>
          controller ??
              LiveCanController(
                webSocketService: webSocketService,
                signalStore: signalStore,
              ),
        ),
      ],
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
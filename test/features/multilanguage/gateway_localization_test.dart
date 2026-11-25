import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:mobile_companion_app/features/gateway/screens/connection_screen.dart';
import 'package:mobile_companion_app/features/gateway/models/connection_failure.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';
import 'package:mobile_companion_app/features/gateway/widgets/delete_gateway_dialog.dart';
import 'package:mobile_companion_app/features/gateway/services/can_ports_service.dart';
import 'package:mobile_companion_app/features/gateway/widgets/can_port_selector.dart';

void main() {
  Future<void> pumpScreen(
      WidgetTester tester, {
        String language = 'de',
        String host = '',
        String port = '',
        List<GatewayInfo> savedGateways = const [],
        Future<void> Function(String, String)? onConnect,
      }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(language),
        supportedLocales: const [
          Locale('en'),
          Locale('de'),
        ],
        localizationsDelegates:
        GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: ConnectionScreen(
            initialHost: host,
            initialPort: port,
            savedGateways: savedGateways,
            onConnect: onConnect ?? (host, port) async {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    final germanButton = find.text('Verbinden');
    final button = germanButton.evaluate().isNotEmpty
        ? germanButton
        : find.text('Connect');

    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  group('Gateway screen localization', () {
    testWidgets('Displays English texts', (tester) async {
      await pumpScreen(tester, language: 'en');

      expect(
        find.text('Connect to a CAN gateway'),
        findsOneWidget,
      );
      expect(find.text('Simulated data'), findsOneWidget);
      expect(find.text('Gateway address'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
    });

    testWidgets('Displays German texts', (tester) async {
      await pumpScreen(tester);

      expect(
        find.text('Mit einem CAN-Gateway verbinden'),
        findsOneWidget,
      );
      expect(find.text('Simulierte Daten'), findsOneWidget);
      expect(find.text('Gateway-Adresse'), findsOneWidget);
      expect(find.text('Verbinden'), findsOneWidget);
    });

    testWidgets('Displays saved gateways in German',
            (tester) async {
          await pumpScreen(
            tester,
            savedGateways: const [
              GatewayInfo(
                name: 'Test Gateway',
                host: '192.168.0.100',
                port: 8080,
              ),
            ],
          );

          await tester.drag(
            find.byType(ListView),
            const Offset(0, -300),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Gespeicherte Gateways'),
            findsOneWidget,
          );
        });
  });

  group('Gateway validation localization', () {
    testWidgets('Empty address shows German validation error',
            (tester) async {
          await pumpScreen(tester);

          await submit(tester);

          expect(
            find.text('Gateway-Adresse ist erforderlich'),
            findsOneWidget,
          );
        });

    testWidgets('Invalid port shows German validation error',
            (tester) async {
          await pumpScreen(
            tester,
            host: '192.168.0.100',
            port: '99999',
          );

          await submit(tester);

          expect(
            find.text(
              'Der Port muss zwischen 1 und 65535 liegen',
            ),
            findsOneWidget,
          );
        });
  });

  group('Connection failure localization', () {
    testWidgets('Failed connection shows German retry button',
            (tester) async {
          await pumpScreen(
            tester,
            host: '192.168.0.100',
            port: '8080',
            onConnect: (host, port) async {
              throw const ConnectionFailure(
                ConnectionFailureType.connectionRefused,
              );
            },
          );

          await submit(tester);

          expect(
            find.text('Erneut versuchen'),
            findsOneWidget,
          );
        });

    testWidgets('Connection failure shows German error message',
            (tester) async {
          await pumpScreen(
            tester,
            host: '192.168.0.100',
            port: '8080',
            onConnect: (host, port) async {
              throw const ConnectionFailure(
                ConnectionFailureType.connectionRefused,
              );
            },
          );

          await submit(tester);

          expect(
            find.text(
              'Das Gerät hat die Verbindung abgelehnt. '
                  'Überprüfen Sie die Portnummer.',
            ),
            findsOneWidget,
          );
        });
  });

  group('Delete gateway localization', () {
    testWidgets('Delete dialog displays German texts',
            (tester) async {
          const gateway = GatewayInfo(
            name: 'Test Gateway',
            host: '192.168.0.100',
            port: 8080,
          );

          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('de'),
              supportedLocales: const [
                Locale('en'),
                Locale('de'),
              ],
              localizationsDelegates:
              GlobalMaterialLocalizations.delegates,
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () {
                        confirmDeleteGateway(context, gateway);
                      },
                      child: const Text('Open dialog'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          await tester.tap(find.text('Open dialog'));
          await tester.pumpAndSettle();

          expect(find.text('Gateway löschen'), findsOneWidget);
          expect(find.text('Abbrechen'), findsOneWidget);
          expect(find.text('Löschen'), findsOneWidget);
        });
  });

  group('CAN port localization', () {
    Future<void> pumpSelector(
        WidgetTester tester,
        http.Client client,
        ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
          ],
          localizationsDelegates:
          GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: CanPortSelector(
              gateway: const GatewayInfo(
                name: 'Test Gateway',
                host: '192.168.0.100',
                port: 8080,
              ),
              selectedPort: null,
              onSelected: (_) {},
              service: CanPortsService(client: client),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    for (final count in [1, 2, 5]) {
      testWidgets('Displays $count CAN ports in German',
              (tester) async {
            final client = MockClient((request) async {
              return http.Response(
                jsonEncode({
                  'ports': List.generate(
                    count,
                        (index) => {
                      'name': 'CAN$index',
                      'halName': 'can$index',
                      'enabled': true,
                    },
                  ),
                }),
                200,
              );
            });

            addTearDown(client.close);

            await pumpSelector(tester, client);

            expect(
              find.text(count == 1 ? '1 Port' : '$count Ports'),
              findsOneWidget,
            );
          });
    }

    testWidgets('Failed CAN port fetch shows German error',
            (tester) async {
          final client = MockClient((request) async {
            return http.Response('', 503);
          });

          addTearDown(client.close);

          await pumpSelector(tester, client);

          expect(
            find.text(
              'Das Gateway konnte die CAN-Ports nicht bereitstellen.',
            ),
            findsOneWidget,
          );
        });

    testWidgets('Failed CAN port fetch shows German retry button',
            (tester) async {
          final client = MockClient((request) async {
            return http.Response('', 503);
          });

          addTearDown(client.close);

          await pumpSelector(tester, client);

          expect(
            find.text('Erneut versuchen'),
            findsOneWidget,
          );
        });
  });
}
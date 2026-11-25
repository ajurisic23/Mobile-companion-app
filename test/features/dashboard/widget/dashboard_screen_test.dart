import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile_companion_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobile_companion_app/features/can/state/live_can_controller.dart';
import 'package:mobile_companion_app/features/can/state/live_signal_store.dart';
import 'package:mobile_companion_app/features/gateway/models/can_port.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';
import 'package:mobile_companion_app/features/gateway/services/can_ports_service.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_health_service.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_websocket_service.dart';
import 'package:mobile_companion_app/features/gateway/state/active_gateway_controller.dart';

const _gateway = GatewayInfo(
  name: 'Address 1',
  host: '192.168.0.100',
  port: 10000,
);

const _otherGateway = GatewayInfo(
  name: 'Address 2',
  host: '192.168.0.101',
  port: 8080,
);

const _can0 = CanPort(
  name: 'can0',
  halName: 'CAN1',
  enabled: true,
);

const _can1 = CanPort(
  name: 'can1',
  halName: 'CAN2',
  enabled: true,
);

class _FakeCanPortsService extends CanPortsService {
  final List<String> calls = [];

  @override
  Future<List<CanPort>> fetchPorts({
    required String host,
    required int port,
  }) async {
    calls.add('$host:$port');
    return [_can0, _can1];
  }
}

class _FakeHealthService extends GatewayHealthService {
  @override
  Future<GatewayHealthStatus> checkHealth({
    required String address,
    required int port,
  }) async {
    return GatewayHealthStatus.available;
  }
}

class _FakeWebSocketService extends GatewayWebSocketService {
  final List<String> connectionCalls = [];

  int disconnectCalls = 0;

  bool shouldFail = false;

  Completer<void>? connectionCompleter;

  void Function(String message)? _onMessage;

  GatewayWebSocketStatus _fakeStatus =
      GatewayWebSocketStatus.disconnected;

  @override
  GatewayWebSocketStatus get status => _fakeStatus;

  @override
  bool get isConnected =>
      _fakeStatus == GatewayWebSocketStatus.connected;

  @override
  Future<void> connect({
    required String host,
    required int port,
    required String canPort,
    required void Function(String message) onMessage,
  }) async {
    connectionCalls.add('$host:$port/$canPort');

    _fakeStatus = GatewayWebSocketStatus.connecting;

    if (connectionCompleter != null) {
      await connectionCompleter!.future;
    }

    if (shouldFail) {
      _fakeStatus = GatewayWebSocketStatus.error;
      throw Exception('Connection failed');
    }

    _onMessage = onMessage;

    _fakeStatus = GatewayWebSocketStatus.connected;
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;

    _onMessage = null;

    _fakeStatus = GatewayWebSocketStatus.disconnected;
  }

  void emit(String message) {
    _onMessage?.call(message);
  }
}

const _rawCanMessage = '''
{
  "type": "parsed",
  "port": "can1",
  "timestamp": 1795472175760,
  "messages": [
    {
      "id": 217056256,
      "category": "known",
      "group": "ELECTRONIC ENGINE CONTROLLER 1",
      "timestamp": 1795472174565,
      "variables": [
        {
          "name": "Engine speed",
          "tag": "engine_speed",
          "type": "WORD",
          "value": 1200,
          "unit": "rpm"
        }
      ]
    }
  ]
}
''';

Widget _wrap(
    ActiveGatewayController controller,
    CanPortsService service, {
      _FakeWebSocketService? webSocketService,
    }) {
  final socketService =
      webSocketService ?? _FakeWebSocketService();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ActiveGatewayController>.value(
        value: controller,
      ),

      ChangeNotifierProvider<LiveSignalStore>(
        create: (_) => LiveSignalStore(),
      ),

      ChangeNotifierProvider<LiveCanController>(
        create: (context) => LiveCanController(
          webSocketService: socketService,
          signalStore: context.read<LiveSignalStore>(),
        ),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: DashboardScreen(
          canPortsService: service,
          gatewayHealthService: _FakeHealthService(),
        ),
      ),
    ),
  );
}

Future<void> _selectPort(
    WidgetTester tester,
    String portLabel,
    ) async {
  await tester.tap(
    find.byType(DropdownButton<CanPort>),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));

  await tester.tap(find.text(portLabel).last);

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

void main() {
  testWidgets(
    'shows the title and asks to connect without a gateway',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ActiveGatewayController(),
          _FakeCanPortsService(),
        ),
      );

      expect(find.text('Live Dashboard'), findsOneWidget);

      expect(
        find.text('Connect to a gateway to see its CAN ports.'),
        findsOneWidget,
      );

      expect(
        find.text('Select a gateway'),
        findsOneWidget,
      );

      expect(find.text('Active'), findsNothing);
    },
  );

  testWidgets(
    'shows the ports of the active gateway',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      final service = _FakeCanPortsService();

      await tester.pumpWidget(
        _wrap(controller, service),
      );

      await tester.pumpAndSettle();

      expect(service.calls, ['192.168.0.100:10000']);

      expect(find.text('2 ports'), findsOneWidget);
    },
  );

  testWidgets(
    'shows the address and the status of the active gateway',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      await tester.pumpWidget(
        _wrap(controller, _FakeCanPortsService()),
      );

      await tester.pumpAndSettle();

      expect(find.text('192.168.0.100'), findsOneWidget);

      expect(find.text('Active'), findsOneWidget);
    },
  );

  testWidgets(
    'loads the ports when a gateway becomes active',
        (tester) async {
      final controller = ActiveGatewayController();

      final service = _FakeCanPortsService();

      await tester.pumpWidget(
        _wrap(controller, service),
      );

      controller.selectGateway(_gateway);

      await tester.pumpAndSettle();

      expect(service.calls, ['192.168.0.100:10000']);

      expect(find.text('2 ports'), findsOneWidget);

      expect(find.text('Active'), findsOneWidget);
    },
  );

  testWidgets(
    'selecting a port stores it in the controller',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      await tester.pumpWidget(
        _wrap(controller, _FakeCanPortsService()),
      );

      await tester.pumpAndSettle();

      await _selectPort(tester, 'can1 (CAN2)');

      expect(controller.port, _can1);
    },
  );

  testWidgets(
    'changing the gateway clears the port and loads new ports',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      final service = _FakeCanPortsService();

      await tester.pumpWidget(
        _wrap(controller, service),
      );

      await tester.pumpAndSettle();

      controller.selectPort(_can0);

      await tester.pump();
      await tester.pump();

      controller.selectGateway(_otherGateway);

      await tester.pumpAndSettle();

      expect(controller.port, isNull);

      expect(
        service.calls,
        [
          '192.168.0.100:10000',
          '192.168.0.101:8080',
        ],
      );

      expect(
        find.text('Select a CAN port'),
        findsWidgets,
      );

      expect(
        find.text('192.168.0.101'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows port selection state when no port is selected',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      await tester.pumpWidget(
        _wrap(controller, _FakeCanPortsService()),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(
          'Choose a CAN port to start receiving live data.',
        ),
        findsOneWidget,
      );

      expect(
        find.byType(SegmentedButton<String>),
        findsNothing,
      );
    },
  );

  testWidgets(
    'automatically connects when a CAN port is selected',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      final socketService = _FakeWebSocketService();

      await tester.pumpWidget(
        _wrap(
          controller,
          _FakeCanPortsService(),
          webSocketService: socketService,
        ),
      );

      await tester.pumpAndSettle();

      await _selectPort(tester, 'can1 (CAN2)');

      expect(
        socketService.connectionCalls,
        ['192.168.0.100:10000/can1'],
      );

      expect(socketService.isConnected, isTrue);

      expect(
        find.text('Start live CAN'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'shows loading state while connecting',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      final socketService = _FakeWebSocketService()
        ..connectionCompleter = Completer<void>();

      await tester.pumpWidget(
        _wrap(
          controller,
          _FakeCanPortsService(),
          webSocketService: socketService,
        ),
      );

      await tester.pumpAndSettle();

      await _selectPort(tester, 'can1 (CAN2)');

      expect(
        find.text('Connecting...'),
        findsOneWidget,
      );

      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );

      socketService.connectionCompleter!.complete();

      await tester.pump();
      await tester.pump();

      expect(
        find.text('Connecting...'),
        findsNothing,
      );

      expect(
        find.text('Waiting for CAN signals...'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows waiting state after successful connection',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      final socketService = _FakeWebSocketService();

      await tester.pumpWidget(
        _wrap(
          controller,
          _FakeCanPortsService(),
          webSocketService: socketService,
        ),
      );

      await tester.pumpAndSettle();

      await _selectPort(tester, 'can1 (CAN2)');

      expect(
        find.text('Waiting for CAN signals...'),
        findsOneWidget,
      );

      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );

      expect(
        find.byType(SegmentedButton<String>),
        findsNothing,
      );
    },
  );

  testWidgets(
    'shows an error when the CAN connection fails',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      final socketService = _FakeWebSocketService()
        ..shouldFail = true;

      await tester.pumpWidget(
        _wrap(
          controller,
          _FakeCanPortsService(),
          webSocketService: socketService,
        ),
      );

      await tester.pumpAndSettle();

      await _selectPort(tester, 'can1 (CAN2)');

      expect(
        find.text('Connection failed'),
        findsOneWidget,
      );

      expect(
        find.text(
          'Unable to connect to the selected CAN port.',
        ),
        findsOneWidget,
      );

      expect(
        find.byType(SegmentedButton<String>),
        findsNothing,
      );

      expect(socketService.isConnected, isFalse);
    },
  );

  testWidgets(
    'automatically displays received CAN signals',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      final socketService = _FakeWebSocketService();

      await tester.pumpWidget(
        _wrap(
          controller,
          _FakeCanPortsService(),
          webSocketService: socketService,
        ),
      );

      await tester.pumpAndSettle();

      await _selectPort(tester, 'can1 (CAN2)');

      socketService.emit(_rawCanMessage);

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Waiting for CAN signals...'),
        findsNothing,
      );

      expect(find.text('Engine speed'), findsOneWidget);

      expect(
        find.textContaining('1200'),
        findsOneWidget,
      );

      expect(
        find.byType(SegmentedButton<String>),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'changing the CAN port reconnects and clears old signals',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      final socketService = _FakeWebSocketService();

      await tester.pumpWidget(
        _wrap(
          controller,
          _FakeCanPortsService(),
          webSocketService: socketService,
        ),
      );

      await tester.pumpAndSettle();

      await _selectPort(tester, 'can1 (CAN2)');

      socketService.emit(_rawCanMessage);

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Engine speed'), findsOneWidget);

      final previousDisconnectCalls =
          socketService.disconnectCalls;

      await _selectPort(tester, 'can0 (CAN1)');

      expect(controller.port, _can0);

      expect(
        socketService.connectionCalls,
        [
          '192.168.0.100:10000/can1',
          '192.168.0.100:10000/can0',
        ],
      );

      expect(
        socketService.disconnectCalls,
        greaterThan(previousDisconnectCalls),
      );

      expect(find.text('Engine speed'), findsNothing);

      expect(
        find.text('Waiting for CAN signals...'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'switching visualization does not reconnect the CAN port',
        (tester) async {
      final controller =
      ActiveGatewayController()..selectGateway(_gateway);

      final socketService = _FakeWebSocketService();

      await tester.pumpWidget(
        _wrap(
          controller,
          _FakeCanPortsService(),
          webSocketService: socketService,
        ),
      );

      await tester.pumpAndSettle();

      await _selectPort(tester, 'can1 (CAN2)');

      socketService.emit(_rawCanMessage);

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      final previousDisconnectCalls =
          socketService.disconnectCalls;

      await tester.tap(find.byIcon(Icons.view_list));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();

      expect(
        socketService.connectionCalls,
        ['192.168.0.100:10000/can1'],
      );

      expect(
        socketService.disconnectCalls,
        previousDisconnectCalls,
      );

      expect(socketService.isConnected, isTrue);

      expect(find.text('Engine speed'), findsOneWidget);
    },
  );
}
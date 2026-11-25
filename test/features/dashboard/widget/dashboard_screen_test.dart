import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:mobile_companion_app/features/gateway/models/can_port.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';
import 'package:mobile_companion_app/features/gateway/services/can_ports_service.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_health_service.dart';
import 'package:mobile_companion_app/features/gateway/state/active_gateway_controller.dart';
import 'package:provider/provider.dart';
import 'package:mobile_companion_app/features/can/state/live_signal_store.dart';

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

const _can0 = CanPort(name: 'can0', halName: 'CAN1', enabled: true);
const _can1 = CanPort(name: 'can1', halName: 'CAN2', enabled: true);

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

Widget _wrap(
    ActiveGatewayController controller,
    CanPortsService service,
    ) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ActiveGatewayController>.value(
        value: controller,
      ),
      ChangeNotifierProvider<LiveSignalStore>(
        create: (_) => LiveSignalStore(),
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

void main() {
  testWidgets('shows the title and asks to connect without a gateway',
          (tester) async {
        await tester.pumpWidget(
          _wrap(ActiveGatewayController(), _FakeCanPortsService()),
        );

        expect(find.text('Live Dashboard'), findsOneWidget);
        expect(find.text('Connect to a gateway to see its CAN ports.'),
            findsOneWidget);
        expect(find.text('Active'), findsNothing);
      });

  testWidgets('shows the ports of the active gateway', (tester) async {
    final controller = ActiveGatewayController()..selectGateway(_gateway);
    final service = _FakeCanPortsService();

    await tester.pumpWidget(_wrap(controller, service));
    await tester.pumpAndSettle();

    expect(service.calls, ['192.168.0.100:10000']);
    expect(find.text('2 ports'), findsOneWidget);
  });

  testWidgets('shows the address and the status of the active gateway',
          (tester) async {
        final controller = ActiveGatewayController()..selectGateway(_gateway);

        await tester.pumpWidget(_wrap(controller, _FakeCanPortsService()));
        await tester.pumpAndSettle();

        expect(find.text('192.168.0.100'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
      });

  testWidgets('loads the ports when a gateway becomes active', (tester) async {
    final controller = ActiveGatewayController();
    final service = _FakeCanPortsService();

    await tester.pumpWidget(_wrap(controller, service));
    controller.selectGateway(_gateway);
    await tester.pumpAndSettle();

    expect(service.calls, ['192.168.0.100:10000']);
    expect(find.text('2 ports'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('selecting a port stores it in the controller', (tester) async {
    final controller = ActiveGatewayController()..selectGateway(_gateway);

    await tester.pumpWidget(_wrap(controller, _FakeCanPortsService()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<CanPort>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('can1 (CAN2)').last);
    await tester.pumpAndSettle();

    expect(controller.port, _can1);
  });

  testWidgets('changing the gateway clears the port and loads new ports',
          (tester) async {
        final controller = ActiveGatewayController()..selectGateway(_gateway);
        final service = _FakeCanPortsService();

        await tester.pumpWidget(_wrap(controller, service));
        await tester.pumpAndSettle();
        controller.selectPort(_can0);
        await tester.pumpAndSettle();

        controller.selectGateway(_otherGateway);
        await tester.pumpAndSettle();

        expect(controller.port, isNull);
        expect(service.calls, ['192.168.0.100:10000', '192.168.0.101:8080']);
        expect(find.text('Select a CAN port'), findsOneWidget);
        expect(find.text('192.168.0.101'), findsOneWidget);
      });
}
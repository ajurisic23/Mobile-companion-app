import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';
import 'package:mobile_companion_app/features/gateway/screens/gateway_screen.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_connection_service.dart';
import 'package:mobile_companion_app/features/gateway/services/gateway_repository.dart';

class _FakeRepository implements GatewayRepository {
  _FakeRepository([List<GatewayInfo> initial = const []])
      : gateways = [...initial];

  final List<GatewayInfo> gateways;

  @override
  Future<List<GatewayInfo>> getAll() async => List.of(gateways);

  @override
  Future<void> save(GatewayInfo gateway) async {
    gateways.removeWhere(gateway.hasSameAddressAs);
    gateways.add(gateway);
  }

  @override
  Future<void> update(GatewayInfo original, GatewayInfo updated) async {
    gateways.removeWhere(original.hasSameAddressAs);
    gateways.add(updated);
  }

  @override
  Future<void> delete(GatewayInfo gateway) async {
    gateways.removeWhere(gateway.hasSameAddressAs);
  }
}

class _FakeConnectionService extends GatewayConnectionService {
  _FakeConnectionService({this.error});

  final Object? error;
  final List<String> calls = [];

  @override
  Future<void> connect(String host, String port) async {
    calls.add('$host:$port');
    final failure = error;
    if (failure != null) throw failure;
  }
}

const _saved = GatewayInfo(
  name: 'Machine 1',
  host: '192.168.0.100',
  port: 10000,
);

Future<void> _pumpScreen(
    WidgetTester tester, {
      required GatewayRepository repository,
      required GatewayConnectionService service,
    }) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: GatewayScreen(
          repository: repository,
          connectionService: service,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _connectTo(
    WidgetTester tester, {
      required String host,
      String port = '',
    }) async {
  await tester.enterText(find.byType(TextFormField).at(0), host);
  await tester.enterText(find.byType(TextFormField).at(1), port);
  await tester.tap(find.text('Connect'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the gateways from the repository', (tester) async {
    await _pumpScreen(
      tester,
      repository: _FakeRepository([_saved]),
      service: _FakeConnectionService(),
    );

    expect(find.text('Saved gateways'), findsOneWidget);
    expect(find.text('Machine 1'), findsOneWidget);
    expect(find.text('192.168.0.100:10000'), findsOneWidget);
  });

  testWidgets('hides the saved gateways section when nothing is saved',
          (tester) async {
        await _pumpScreen(
          tester,
          repository: _FakeRepository(),
          service: _FakeConnectionService(),
        );

        expect(find.text('Saved gateways'), findsNothing);
      });

  testWidgets('saves a new gateway with the default port after connecting',
          (tester) async {
        final repository = _FakeRepository();
        final service = _FakeConnectionService();

        await _pumpScreen(tester, repository: repository, service: service);
        await _connectTo(tester, host: '192.168.0.100');

        expect(service.calls, ['192.168.0.100:']);
        expect(repository.gateways, [
          const GatewayInfo(
            name: '192.168.0.100:10000',
            host: '192.168.0.100',
            port: 10000,
          ),
        ]);
        expect(find.text('Saved gateways'), findsOneWidget);
      });

  testWidgets('saves the gateway with the port that was entered',
          (tester) async {
        final repository = _FakeRepository();

        await _pumpScreen(
          tester,
          repository: repository,
          service: _FakeConnectionService(),
        );
        await _connectTo(tester, host: '192.168.0.101', port: '8080');

        expect(repository.gateways, [
          const GatewayInfo(
            name: '192.168.0.101:8080',
            host: '192.168.0.101',
            port: 8080,
          ),
        ]);
      });

  testWidgets('does not save a gateway when connecting fails', (tester) async {
    final repository = _FakeRepository();

    await _pumpScreen(
      tester,
      repository: repository,
      service: _FakeConnectionService(error: Exception('boom')),
    );
    await _connectTo(tester, host: '192.168.0.200');

    expect(repository.gateways, isEmpty);
    expect(find.text('Saved gateways'), findsNothing);
  });

  testWidgets('does not duplicate or rename an already saved gateway',
          (tester) async {
        final repository = _FakeRepository([_saved]);

        await _pumpScreen(
          tester,
          repository: repository,
          service: _FakeConnectionService(),
        );
        await _connectTo(tester, host: '192.168.0.100');

        expect(repository.gateways, [_saved]);
      });

  testWidgets('connecting to a saved gateway uses its address and port',
          (tester) async {
        final repository = _FakeRepository([_saved]);
        final service = _FakeConnectionService();

        await _pumpScreen(tester, repository: repository, service: service);
        await tester.tap(find.text('Machine 1'));
        await tester.pumpAndSettle();

        expect(service.calls, ['192.168.0.100:10000']);
        expect(repository.gateways, [_saved]);
      });

  testWidgets('deleting a gateway removes it from the repository and the list',
          (tester) async {
        final repository = _FakeRepository([_saved]);

        await _pumpScreen(
          tester,
          repository: repository,
          service: _FakeConnectionService(),
        );
        await tester.tap(find.byTooltip('Delete'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(repository.gateways, isEmpty);
        expect(find.text('Saved gateways'), findsNothing);
      });

  testWidgets('cancelling the confirmation keeps the gateway', (tester) async {
    final repository = _FakeRepository([_saved]);

    await _pumpScreen(
      tester,
      repository: repository,
      service: _FakeConnectionService(),
    );
    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.gateways, [_saved]);
    expect(find.text('Machine 1'), findsOneWidget);
  });
}
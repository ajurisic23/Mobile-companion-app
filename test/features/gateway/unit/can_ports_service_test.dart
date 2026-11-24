import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_companion_app/features/gateway/models/can_port.dart';
import 'package:mobile_companion_app/features/gateway/services/can_ports_service.dart';

const _host = '192.168.0.100';
const _port = 10000;

final _portsBody = jsonEncode({
  'ports': [
    {'name': 'can0', 'halName': 'CAN1', 'enabled': true},
    {'name': 'can1', 'halName': 'CAN2', 'enabled': true},
  ],
});

Future<void> _expectFailure(
    MockClient client,
    CanPortsFailureType type,
    ) async {
  final service = CanPortsService(client: client);

  await expectLater(
    service.fetchPorts(host: _host, port: _port),
    throwsA(isA<CanPortsException>().having((e) => e.type, 'type', type)),
  );
}

void main() {
  test('requests the ports endpoint of the gateway', () async {
    Uri? requested;
    final service = CanPortsService(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(_portsBody, 200);
      }),
    );

    await service.fetchPorts(host: _host, port: _port);

    expect(requested.toString(), 'http://192.168.0.100:10000/api/v1/can/ports');
  });

  test('returns the ports from the response', () async {
    final service = CanPortsService(
      client: MockClient((request) async => http.Response(_portsBody, 200)),
    );

    final ports = await service.fetchPorts(host: _host, port: _port);

    expect(ports, const [
      CanPort(name: 'can0', halName: 'CAN1', enabled: true),
      CanPort(name: 'can1', halName: 'CAN2', enabled: true),
    ]);
  });

  test('returns an empty list when the gateway has no ports', () async {
    final service = CanPortsService(
      client: MockClient(
            (request) async => http.Response(jsonEncode({'ports': []}), 200),
      ),
    );

    expect(await service.fetchPorts(host: _host, port: _port), isEmpty);
  });

  test('reports a timeout', () async {
    await _expectFailure(
      MockClient((request) async => throw TimeoutException('too slow')),
      CanPortsFailureType.timeout,
    );
  });

  test('reports a network error for a socket exception', () async {
    await _expectFailure(
      MockClient((request) async => throw const SocketException('no route')),
      CanPortsFailureType.network,
    );
  });

  test('reports a network error for a client exception', () async {
    await _expectFailure(
      MockClient((request) async => throw http.ClientException('failed')),
      CanPortsFailureType.network,
    );
  });

  test('reports the gateway as unavailable for an error status', () async {
    await _expectFailure(
      MockClient((request) async => http.Response('error', 500)),
      CanPortsFailureType.unavailable,
    );
    await _expectFailure(
      MockClient((request) async => http.Response('not found', 404)),
      CanPortsFailureType.unavailable,
    );
  });

  test('reports an invalid response for a body that is not JSON', () async {
    await _expectFailure(
      MockClient((request) async => http.Response('not json', 200)),
      CanPortsFailureType.invalidResponse,
    );
  });

  test('reports an invalid response for an unexpected JSON shape', () async {
    await _expectFailure(
      MockClient((request) async => http.Response('[]', 200)),
      CanPortsFailureType.invalidResponse,
    );
    await _expectFailure(
      MockClient(
            (request) async => http.Response(jsonEncode({'other': 1}), 200),
      ),
      CanPortsFailureType.invalidResponse,
    );
  });

  test('every failure has a readable message', () {
    for (final type in CanPortsFailureType.values) {
      expect(CanPortsException(type).message, isNotEmpty);
    }
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/gateway/models/can_port.dart';
import 'package:mobile_companion_app/features/gateway/models/gateway_info.dart';
import 'package:mobile_companion_app/features/gateway/state/active_gateway_controller.dart';

const _first = GatewayInfo(
  name: 'Address 1',
  host: '192.168.0.100',
  port: 10000,
);

const _renamed = GatewayInfo(
  name: 'Renamed',
  host: '192.168.0.100',
  port: 10000,
);

const _second = GatewayInfo(
  name: 'Address 2',
  host: '192.168.0.101',
  port: 8080,
);

const _can0 = CanPort(name: 'can0', halName: 'CAN1', enabled: true);
const _can1 = CanPort(name: 'can1', halName: 'CAN2', enabled: true);

void main() {
  late ActiveGatewayController controller;
  late int notifications;

  setUp(() {
    controller = ActiveGatewayController();
    notifications = 0;
    controller.addListener(() => notifications++);
  });

  tearDown(() => controller.dispose());

  test('starts without a gateway and a port', () {
    expect(controller.gateway, isNull);
    expect(controller.port, isNull);
  });

  group('selecting a gateway', () {
    test('sets the gateway and notifies listeners', () {
      controller.selectGateway(_first);

      expect(controller.gateway, _first);
      expect(notifications, 1);
    });

    test('does not notify when the same gateway is selected again', () {
      controller.selectGateway(_first);
      controller.selectGateway(_first);

      expect(notifications, 1);
    });

    test('clears the port when a different gateway is selected', () {
      controller.selectGateway(_first);
      controller.selectPort(_can0);
      controller.selectGateway(_second);

      expect(controller.gateway, _second);
      expect(controller.port, isNull);
    });

    test('keeps the port when the same address is selected again', () {
      controller.selectGateway(_first);
      controller.selectPort(_can0);
      controller.selectGateway(_renamed);

      expect(controller.gateway, _renamed);
      expect(controller.port, _can0);
    });
  });

  group('selecting a port', () {
    test('sets the port and notifies listeners', () {
      controller.selectGateway(_first);
      controller.selectPort(_can1);

      expect(controller.port, _can1);
      expect(notifications, 2);
    });

    test('is ignored when no gateway is selected', () {
      controller.selectPort(_can0);

      expect(controller.port, isNull);
      expect(notifications, 0);
    });

    test('does not notify when the same port is selected again', () {
      controller.selectGateway(_first);
      controller.selectPort(_can0);
      controller.selectPort(_can0);

      expect(notifications, 2);
    });
  });

  group('clear', () {
    test('removes the gateway and the port and notifies listeners', () {
      controller.selectGateway(_first);
      controller.selectPort(_can0);
      controller.clear();

      expect(controller.gateway, isNull);
      expect(controller.port, isNull);
      expect(notifications, 3);
    });

    test('does not notify when nothing is selected', () {
      controller.clear();

      expect(notifications, 0);
    });
  });
}
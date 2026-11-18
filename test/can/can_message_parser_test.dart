import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/can/services/can_message_parser.dart';

void main() {
  group('CanMessageParser', () {
    const parser = CanMessageParser();

    test('parses a valid CAN message from the gateway', () {
      const responseBody = '''
      [
        {
          "id": 217056000,
          "category": "known",
          "group": "ELECTRONIC ENGINE CONTROLLER 2",
          "timestamp": 1791622364123,
          "variables": [
            {
              "name": "Accelerator pedal position",
              "tag": "accelerator_pedal_position",
              "type": "BYTE",
              "value": "41.6",
              "unit": "%"
            }
          ],
          "latitude": 0,
          "longitude": 0,
          "altitude": 0
        }
      ]
      ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages.length, 1);

      final message = messages.first;

      expect(message.id, 217056000);
      expect(message.category, 'known');
      expect(message.group, 'ELECTRONIC ENGINE CONTROLLER 2');
      expect(message.timestamp, 1791622364123);

      expect(message.variables.length, 1);

      final signal = message.variables.first;

      expect(signal.name, 'Accelerator pedal position');
      expect(signal.tag, 'accelerator_pedal_position');
      expect(signal.type, 'BYTE');
      expect(signal.value, '41.6');
      expect(signal.unit, '%');

      expect(message.latitude, 0.0);
      expect(message.longitude, 0.0);
      expect(message.altitude, 0.0);
    });

    test('returns empty list for invalid JSON', () {
      const responseBody = 'this is not valid JSON';

      final messages = parser.parseMessages(responseBody);

      expect(messages, isEmpty);
    });

    test('skips a message with missing required fields', () {
      const responseBody = '''
        [
          {
            "id": 217056000,
            "category": "known",
            "variables": []
          }
        ]
        ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages, isEmpty);
    });

    test('skips a message with invalid signal value type', () {
      const responseBody = '''
        [
          {
            "id": 217056000,
            "category": "known",
            "group": "ELECTRONIC ENGINE CONTROLLER 2",
            "timestamp": 1791622364123,
            "variables": [
              {
                "name": "Accelerator pedal position",
                "tag": "accelerator_pedal_position",
                "type": "BYTE",
                "value": 41.6,
                "unit": "%"
              }
            ],
            "latitude": 0,
            "longitude": 0,
            "altitude": 0
          }
        ]
        ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages, isEmpty);
    });

    test('skips invalid messages and keeps valid ones', () {
      const responseBody = '''
        [
          {
            "id": 100,
            "category": "known",
            "group": "Engine",
            "timestamp": 1791622364123,
            "variables": [
              {
                "name": "Engine speed",
                "tag": "engine_speed",
                "type": "BYTE",
                "value": "1500",
                "unit": "rpm"
              }
            ],
            "latitude": 0,
            "longitude": 0,
            "altitude": 0
          },
          {
            "id": 200,
            "category": "known",
            "variables": []
          },
          {
            "id": 300,
            "category": "known",
            "group": "Engine",
            "timestamp": 1791622364125,
            "variables": [],
            "latitude": 0,
            "longitude": 0,
            "altitude": 0
          }
        ]
        ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages.length, 2);
      expect(messages[0].id, 100);
      expect(messages[1].id, 300);
    });
    test('returns empty list for empty JSON array', () {
      const responseBody = '[]';

      final messages = parser.parseMessages(responseBody);

      expect(messages, isEmpty);
    });
    test('skips a CAN message without variables field', () {
      const responseBody = '''
        [
          {
            "id": 217056000,
            "category": "known",
            "group": "ELECTRONIC ENGINE CONTROLLER 2",
            "timestamp": 1791622364123,
            "latitude": 0,
            "longitude": 0,
            "altitude": 0
          }
        ]
        ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages, isEmpty);
    });
    test('skips a CAN message with invalid variables item', () {
      const responseBody = '''
        [
          {
            "id": 217056000,
            "category": "known",
            "group": "ELECTRONIC ENGINE CONTROLLER 2",
            "timestamp": 1791622364123,
            "variables": [123],
            "latitude": 0,
            "longitude": 0,
            "altitude": 0
          }
        ]
        ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages, isEmpty);
    });
    test('parses a CAN message with empty variables list', () {
      const responseBody = '''
        [
          {
            "id": 217056000,
            "category": "known",
            "group": "ELECTRONIC ENGINE CONTROLLER 2",
            "timestamp": 1791622364123,
            "variables": [],
            "latitude": 0,
            "longitude": 0,
            "altitude": 0
          }
        ]
        ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages.length, 1);
      expect(messages.first.variables, isEmpty);
    });
    test('parses a CAN message with multiple signals', () {
      const responseBody = '''
        [
          {
            "id": 217056000,
            "category": "known",
            "group": "ELECTRONIC ENGINE CONTROLLER 2",
            "timestamp": 1791622364123,
            "variables": [
              {
                "name": "Accelerator pedal position",
                "tag": "accelerator_pedal_position",
                "type": "BYTE",
                "value": "41.6",
                "unit": "%"
              },
              {
                "name": "Engine speed",
                "tag": "engine_speed",
                "type": "WORD",
                "value": "1500",
                "unit": "rpm"
              }
            ],
            "latitude": 0,
            "longitude": 0,
            "altitude": 0
          }
        ]
        ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages.length, 1);
      expect(messages.first.variables.length, 2);

      expect(messages.first.variables[0].name, 'Accelerator pedal position');
      expect(messages.first.variables[0].value, '41.6');
      expect(messages.first.variables[0].unit, '%');

      expect(messages.first.variables[1].name, 'Engine speed');
      expect(messages.first.variables[1].value, '1500');
      expect(messages.first.variables[1].unit, 'rpm');
    });
    test('skips a CAN message when signal value is missing', () {
      const responseBody = '''
        [
          {
            "id": 217056000,
            "category": "known",
            "group": "ELECTRONIC ENGINE CONTROLLER 2",
            "timestamp": 1791622364123,
            "variables": [
              {
                "name": "Accelerator pedal position",
                "tag": "accelerator_pedal_position",
                "type": "BYTE",
                "unit": "%"
              }
            ],
            "latitude": 0,
            "longitude": 0,
            "altitude": 0
          }
        ]
        ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages, isEmpty);
    });
    test('skips a CAN message with invalid timestamp type', () {
      const responseBody = '''
        [
          {
            "id": 217056000,
            "category": "known",
            "group": "ELECTRONIC ENGINE CONTROLLER 2",
            "timestamp": "invalid",
            "variables": [],
            "latitude": 0,
            "longitude": 0,
            "altitude": 0
          }
        ]
        ''';

      final messages = parser.parseMessages(responseBody);

      expect(messages, isEmpty);
    });
  });
}

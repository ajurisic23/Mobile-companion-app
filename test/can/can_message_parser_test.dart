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
  });
}

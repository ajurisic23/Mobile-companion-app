import 'dart:convert';

import '../models/can_message.dart';
import '../models/can_signal.dart';

class CanMessageParser {
  const CanMessageParser();

  CanMessage? parseMessage(Map<String, dynamic> json) {
    try {
      final variablesJson = json['variables'];

      if (variablesJson is! List) {
        return null;
      }

      final signals = <CanSignal>[];

      for (final item in variablesJson) {
        if (item is! Map<String, dynamic>) {
          return null;
        }

        signals.add(
          CanSignal(
            name: item['name'] as String,
            tag: item['tag'] as String,
            type: item['type'] as String,
            value: item['value'] as num,
            unit: item['unit'] as String?,
          ),
        );
      }

      return CanMessage(
        id: json['id'] as int,
        category: json['category'] as String,
        group: json['group'] as String?,
        timestamp: json['timestamp'] as int,
        variables: List.unmodifiable(signals),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        altitude: (json['altitude'] as num?)?.toDouble(),
      );
    } on TypeError {
      return null;
    } on FormatException {
      return null;
    }
  }

  List<CanMessage> parseMessages(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);

      final dynamic messagesJson;

      if (decoded is Map<String, dynamic>) {
        messagesJson = decoded['messages'];
      } else {
        messagesJson = decoded;
      }

      if (messagesJson is! List) {
        return [];
      }

      final messages = <CanMessage>[];

      for (final item in messagesJson) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final message = parseMessage(item);

        if (message != null) {
          messages.add(message);
        }
      }

      return messages;
    } on FormatException {
      return [];
    }
  }

  CanMessage? parseSingleMessage(String rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final messagesJson = decoded['messages'];

      if (messagesJson is List) {
        for (final item in messagesJson) {
          if (item is Map<String, dynamic>) {
            final message = parseMessage(item);

            if (message != null) {
              return message;
            }
          }
        }

        return null;
      }

      return parseMessage(decoded);
    } on FormatException {
      return null;
    }
  }
}
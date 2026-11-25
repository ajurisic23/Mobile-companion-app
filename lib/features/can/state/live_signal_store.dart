import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/can_message.dart';
import '../models/can_signal.dart';
import '../services/can_message_parser.dart';

class LiveSignalEntry {
  const LiveSignalEntry({
    required this.signal,
    this.messageId,
    this.group,
    this.timestamp,
  });

  final CanSignal signal;
  final int? messageId;
  final String? group;
  final int? timestamp;

  String get tag => signal.tag;
  num get value => signal.value;
  String? get unit => signal.unit;
}

class LiveSignalStore extends ChangeNotifier {
  LiveSignalStore({
    this._parser = const CanMessageParser(),
  });

  final CanMessageParser _parser;
  final Map<String, LiveSignalEntry> _entriesByTag = {};

  Map<String, LiveSignalEntry> get entriesByTag =>
      UnmodifiableMapView(_entriesByTag);

  Map<String, CanSignal> get signalsByTag => UnmodifiableMapView({
    for (final entry in _entriesByTag.entries) entry.key: entry.value.signal,
  });

  List<CanSignal> get signals =>
      List.unmodifiable(_entriesByTag.values.map((e) => e.signal));

  LiveSignalEntry? getEntry(String tag) => _entriesByTag[tag];

  CanSignal? getSignal(String tag) => _entriesByTag[tag]?.signal;

  void applyMessages(Iterable<CanMessage> messages) {
    var hasChanges = false;

    for (final message in messages) {
      for (final signal in message.variables) {
        if (signal.tag.isEmpty) continue;

        _entriesByTag[signal.tag] = LiveSignalEntry(
          signal: signal,
          messageId: message.id,
          group: message.group,
          timestamp: message.timestamp,
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void applyRawJson(String rawPayload) {
    final messages = _parser.parseMessages(rawPayload);
    if (messages.isNotEmpty) {
      applyMessages(messages);
    }
  }

  void clear() {
    if (_entriesByTag.isEmpty) return;
    _entriesByTag.clear();
    notifyListeners();
  }

}
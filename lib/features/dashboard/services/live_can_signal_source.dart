import 'dart:async';

import 'package:can_core/can_core.dart';

import '../../can/state/live_signal_store.dart';
import '../interfaces/can_signal_source.dart';

class LiveCanSignalSource implements CanSignalSource {
  LiveCanSignalSource(this._signalStore);

  final LiveSignalStore _signalStore;

  List<SignalDisplayData> _mapSignals() {
    return _signalStore.signals.map((signal) {
      return SignalDisplayData(
        tag: signal.tag,
        name: signal.name,
        value: signal.value.toString(),
        unit: signal.unit,
      );
    }).toList(growable: false);
  }

  @override
  Stream<List<SignalDisplayData>> get signals {
    late final StreamController<List<SignalDisplayData>> controller;

    void emitSignals() {
      controller.add(_mapSignals());
    }

    controller = StreamController<List<SignalDisplayData>>(
      onListen: () {
        _signalStore.addListener(emitSignals);
        emitSignals();
      },
      onCancel: () {
        _signalStore.removeListener(emitSignals);
      },
    );

    return controller.stream;
  }
}
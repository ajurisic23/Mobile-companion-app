import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

import 'widgets/can_signal_gauge_grid.dart';

class CanGaugeView implements CanSignalView {
  const CanGaugeView();

  @override
  String get id => 'gauge';

  @override
  String get label => 'Gauge';

  @override
  IconData get icon => Icons.speed;

  @override
  Widget buildView(List<SignalDisplayData> signals) {
    return CanSignalGaugeGrid(signals: signals);
  }
}
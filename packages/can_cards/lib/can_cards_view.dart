
import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

import 'widgets/can_signal_grid.dart';

class CanCardsView implements CanSignalView {
  const CanCardsView();

  @override
  String get id => 'cards';

  @override
  String get label => 'Cards';

  @override
  IconData get icon => Icons.grid_view;

  @override
  Widget buildView(List<SignalDisplayData> signals) {
    return CanSignalGrid(signals: signals);
  }
}

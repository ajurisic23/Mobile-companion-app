
import 'package:flutter/material.dart';
import 'package:can_core/can_core.dart';

import 'widgets/can_signal_list.dart';

class CanListView implements CanSignalView {
  const CanListView();

  @override
  String get id => 'list';

  @override
  String get label => 'List';

  @override
  IconData get icon => Icons.view_list;

  @override
  Widget buildView(List<SignalDisplayData> signals) {
    return CanSignalList(signals: signals);
  }
}

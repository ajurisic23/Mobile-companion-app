
import 'package:flutter/widgets.dart';

import '../models/signal_display_data.dart';

abstract interface class CanSignalView {
  String get id;

  String get label;

  IconData get icon;

  Widget buildView(List<SignalDisplayData> signals);
}


import 'package:can_core/can_core.dart';

abstract interface class CanSignalSource {
  Stream<List<SignalDisplayData>> get signals;
}

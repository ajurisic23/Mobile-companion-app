import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:can_core/can_core.dart';
import 'package:can_cards/can_cards.dart';
import 'package:can_list/can_list.dart';
import 'package:can_gauge/can_gauge.dart';

import 'package:mobile_companion_app/features/dashboard/generated/can_module_registry.g.dart';
import 'package:mobile_companion_app/features/dashboard/interfaces/can_signal_source.dart';
import 'package:mobile_companion_app/features/dashboard/screens/dashboard_preview_screen.dart';

class _TestCanSignalSource implements CanSignalSource {
  final _controller =
  StreamController<List<SignalDisplayData>>();

  @override
  Stream<List<SignalDisplayData>> get signals =>
      _controller.stream;

  bool get hasListener => _controller.hasListener;

  void emit(List<SignalDisplayData> signals) {
    _controller.add(signals);
  }

  Future<void> dispose() => _controller.close();
}

const _testSignals = [
  SignalDisplayData(
    tag: 'engine_speed',
    name: 'Engine speed',
    value: '1200',
    unit: 'rpm',
  ),
  SignalDisplayData(
    tag: 'fuel_level',
    name: 'Fuel level',
    value: '65',
    unit: '%',
  ),
];

Widget _wrap(
    CanSignalSource source, {
      List<CanSignalView> views = registeredCanViews,
    }) {
  return MaterialApp(
    home: Scaffold(
      body: DashboardPreviewScreen(
        signalSource: source,
        views: views,
      ),
    ),
  );
}

void main() {
  group('Generated CAN module registry', () {
    test('contains all three implemented modules', () {
      expect(registeredCanViews.length, 3);

      expect(
        registeredCanViews[0],
        isA<CanCardsView>(),
      );

      expect(
        registeredCanViews[1],
        isA<CanListView>(),
      );

      expect(
        registeredCanViews[2],
        isA<CanGaugeView>(),
      );
    });

    test('all modules implement the shared interface', () {
      for (final view in registeredCanViews) {
        expect(view, isA<CanSignalView>());
      }
    });

    test('all module identifiers are unique', () {
      final ids = registeredCanViews
          .map((view) => view.id)
          .toList();

      expect(ids.toSet().length, ids.length);
    });

    test('modules are registered in the expected order', () {
      expect(
        registeredCanViews.map((view) => view.id),
        ['cards', 'list', 'gauge'],
      );
    });
  });

  group('Modular dashboard', () {
    late _TestCanSignalSource source;

    setUp(() {
      source = _TestCanSignalSource();
    });

    tearDown(() async {
      await source.dispose();
    });

    testWidgets('shows waiting state before receiving signals',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          expect(
            find.text('Waiting for CAN signals...'),
            findsOneWidget,
          );

          expect(
            find.text('Waiting for incoming live data.'),
            findsOneWidget,
          );

          expect(
            find.byType(CircularProgressIndicator),
            findsOneWidget,
          );

          expect(
            find.byType(SegmentedButton<String>),
            findsNothing,
          );
        });

    testWidgets('automatically selects the first module',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          final selector =
          tester.widget<SegmentedButton<String>>(
            find.byType(SegmentedButton<String>),
          );

          expect(selector.selected, {'cards'});
          expect(find.byType(CanSignalGrid), findsOneWidget);
        });

    testWidgets('displays all registered module options',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          final selector =
          tester.widget<SegmentedButton<String>>(
            find.byType(SegmentedButton<String>),
          );

          expect(selector.segments.length, 3);

          expect(
            selector.segments.map((segment) => segment.value),
            ['cards', 'list', 'gauge'],
          );
        });

    testWidgets('switches from cards to list',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.view_list));
          await tester.pumpAndSettle();

          expect(find.byType(CanSignalList), findsOneWidget);
          expect(find.byType(CanSignalGrid), findsNothing);
        });

    testWidgets('switches from cards to gauge',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.speed));
          await tester.pumpAndSettle();

          final selector =
          tester.widget<SegmentedButton<String>>(
            find.byType(SegmentedButton<String>),
          );

          expect(selector.selected, {'gauge'});

          expect(
            find.byType(CircularProgressIndicator),
            findsNWidgets(4),
          );

          expect(find.byType(CanSignalGrid), findsNothing);
        });

    testWidgets('switches back to cards',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.speed));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.grid_view));
          await tester.pumpAndSettle();

          expect(find.byType(CanSignalGrid), findsOneWidget);

          expect(
            find.byType(CircularProgressIndicator),
            findsNothing,
          );
        });

    testWidgets('all modules display the same CAN signals',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          for (final view in registeredCanViews) {
            await tester.tap(find.byIcon(view.icon));
            await tester.pumpAndSettle();

            expect(find.text('Engine speed'), findsOneWidget);
            expect(find.text('Fuel level'), findsOneWidget);
            expect(find.textContaining('1200'), findsOneWidget);
            expect(find.textContaining('65'), findsOneWidget);
          }
        });

    testWidgets('updates values in the active module',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.speed));
          await tester.pumpAndSettle();

          source.emit(const [
            SignalDisplayData(
              tag: 'engine_speed',
              name: 'Engine speed',
              value: '1800',
              unit: 'rpm',
            ),
          ]);

          await tester.pumpAndSettle();

          expect(find.text('1800'), findsOneWidget);
          expect(find.text('1200'), findsNothing);

          final selector =
          tester.widget<SegmentedButton<String>>(
            find.byType(SegmentedButton<String>),
          );

          expect(selector.selected, {'gauge'});
        });

    testWidgets('preserves latest values when switching modules',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          source.emit(const [
            SignalDisplayData(
              tag: 'engine_speed',
              name: 'Engine speed',
              value: '2400',
              unit: 'rpm',
            ),
          ]);

          await tester.pumpAndSettle();

          for (final view in registeredCanViews) {
            await tester.tap(find.byIcon(view.icon));
            await tester.pumpAndSettle();

            expect(
              find.textContaining('2400'),
              findsOneWidget,
            );

            expect(
              find.textContaining('1200'),
              findsNothing,
            );
          }
        });

    testWidgets('shows waiting state when signals are cleared',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          expect(
            find.byType(CanSignalGrid),
            findsOneWidget,
          );

          source.emit([]);
          await tester.pump();
          await tester.pump();

          expect(
            find.text('Waiting for CAN signals...'),
            findsOneWidget,
          );

          expect(
            find.byType(CircularProgressIndicator),
            findsOneWidget,
          );

          expect(
            find.byType(SegmentedButton<String>),
            findsNothing,
          );

          expect(
            find.byType(CanSignalGrid),
            findsNothing,
          );
        });

    testWidgets('handles an empty module registry',
            (tester) async {
          await tester.pumpWidget(
            _wrap(source, views: const []),
          );

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          expect(
            find.text('No signal display modules available.'),
            findsOneWidget,
          );
        });

    testWidgets('works without the cards module',
            (tester) async {
          final views = registeredCanViews
              .where((view) => view.id != 'cards')
              .toList();

          await tester.pumpWidget(
            _wrap(source, views: views),
          );

          source.emit(_testSignals);
          await tester.pumpAndSettle();

          final selector =
          tester.widget<SegmentedButton<String>>(
            find.byType(SegmentedButton<String>),
          );

          expect(selector.segments.length, 2);
          expect(selector.selected, {'list'});
          expect(find.byType(CanSignalList), findsOneWidget);
          expect(find.byIcon(Icons.grid_view), findsNothing);
        });

    testWidgets('cancels the signal subscription on dispose',
            (tester) async {
          await tester.pumpWidget(_wrap(source));

          expect(source.hasListener, isTrue);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();

          expect(source.hasListener, isFalse);
        });
  });
}
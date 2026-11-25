import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:can_core/can_core.dart';
import 'package:can_cards/can_cards.dart';

void main() {
  const engineSpeed = SignalDisplayData(
    tag: 'engine_speed',
    name: 'Engine speed',
    value: '1244.125',
    unit: 'rpm',
  );

  const currentGear = SignalDisplayData(
    tag: 'current_gear',
    name: 'Current gear',
    value: '3',
  );

  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('CanCardsView', () {
    test('provides correct module metadata', () {
      const view = CanCardsView();

      expect(view.id, 'cards');
      expect(view.label, 'Cards');
      expect(view.icon, Icons.grid_view);
    });

    test('implements the shared CanSignalView interface', () {
      expect(const CanCardsView(), isA<CanSignalView>());
    });

    test('builds a CanSignalGrid', () {
      const view = CanCardsView();

      final widget = view.buildView([engineSpeed]);

      expect(widget, isA<CanSignalGrid>());
    });
  });

  group('CanSignalCard', () {
    testWidgets('displays signal name, value and unit',
            (tester) async {
          await tester.pumpWidget(
            wrap(const CanSignalCard(signal: engineSpeed)),
          );

          expect(find.text('Engine speed'), findsOneWidget);
          expect(find.text('1244.125'), findsOneWidget);
          expect(find.text('rpm'), findsOneWidget);
        });

    testWidgets('displays signal without a unit',
            (tester) async {
          await tester.pumpWidget(
            wrap(const CanSignalCard(signal: currentGear)),
          );

          expect(find.text('Current gear'), findsOneWidget);
          expect(find.text('3'), findsOneWidget);
          expect(find.byType(Text), findsNWidgets(2));
        });

    testWidgets('does not display a blank unit',
            (tester) async {
          const signal = SignalDisplayData(
            tag: 'status',
            name: 'Status',
            value: '1',
            unit: '   ',
          );

          await tester.pumpWidget(
            wrap(const CanSignalCard(signal: signal)),
          );

          expect(find.text('Status'), findsOneWidget);
          expect(find.text('1'), findsOneWidget);
          expect(find.byType(Text), findsNWidgets(2));
        });

    testWidgets('handles long values without overflow',
            (tester) async {
          const signal = SignalDisplayData(
            tag: 'fuel_pressure',
            name: 'Fuel pressure',
            value: '564.3000000000001',
            unit: 'kPa',
          );

          await tester.pumpWidget(
            wrap(
              const Center(
                child: SizedBox(
                  width: 160,
                  height: 170,
                  child: CanSignalCard(signal: signal),
                ),
              ),
            ),
          );

          expect(
            find.text('564.3000000000001'),
            findsOneWidget,
          );

          expect(tester.takeException(), isNull);
        });
  });

  group('CanSignalGrid', () {
    testWidgets('displays multiple CAN signals',
            (tester) async {
          await tester.pumpWidget(
            wrap(
              const CanSignalGrid(
                signals: [engineSpeed, currentGear],
              ),
            ),
          );

          expect(find.byType(CanSignalCard), findsNWidgets(2));
          expect(find.text('Engine speed'), findsOneWidget);
          expect(find.text('Current gear'), findsOneWidget);
        });

    testWidgets('handles an empty signal list',
            (tester) async {
          await tester.pumpWidget(
            wrap(const CanSignalGrid(signals: [])),
          );

          expect(find.byType(CanSignalCard), findsNothing);
          expect(tester.takeException(), isNull);
        });

    testWidgets('updates displayed signal values',
            (tester) async {
          await tester.pumpWidget(
            wrap(
              const CanSignalGrid(signals: [engineSpeed]),
            ),
          );

          expect(find.text('1244.125'), findsOneWidget);

          const updatedSignal = SignalDisplayData(
            tag: 'engine_speed',
            name: 'Engine speed',
            value: '1500',
            unit: 'rpm',
          );

          await tester.pumpWidget(
            wrap(
              const CanSignalGrid(signals: [updatedSignal]),
            ),
          );

          expect(find.text('1500'), findsOneWidget);
          expect(find.text('1244.125'), findsNothing);
        });
  });
}
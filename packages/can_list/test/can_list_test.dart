import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:can_core/can_core.dart';
import 'package:can_list/can_list.dart';

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

  group('CanListView', () {
    test('provides correct module metadata', () {
      const view = CanListView();

      expect(view.id, 'list');
      expect(view.label, 'List');
      expect(view.icon, Icons.view_list);
    });

    test('implements the shared CanSignalView interface', () {
      expect(const CanListView(), isA<CanSignalView>());
    });

    test('builds a CanSignalList', () {
      const view = CanListView();

      final widget = view.buildView([engineSpeed]);

      expect(widget, isA<CanSignalList>());
    });
  });

  group('CanSignalList', () {
    testWidgets('displays signal name, value and unit',
            (tester) async {
          await tester.pumpWidget(
            wrap(
              const CanSignalList(signals: [engineSpeed]),
            ),
          );

          expect(find.text('Engine speed'), findsOneWidget);
          expect(find.text('1244.125 rpm'), findsOneWidget);
        });

    testWidgets('displays signal without a unit',
            (tester) async {
          await tester.pumpWidget(
            wrap(
              const CanSignalList(signals: [currentGear]),
            ),
          );

          expect(find.text('Current gear'), findsOneWidget);
          expect(find.text('3'), findsOneWidget);
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
            wrap(
              const CanSignalList(signals: [signal]),
            ),
          );

          expect(find.text('Status'), findsOneWidget);
          expect(find.text('1'), findsOneWidget);
        });

    testWidgets('displays multiple CAN signals',
            (tester) async {
          await tester.pumpWidget(
            wrap(
              const CanSignalList(
                signals: [engineSpeed, currentGear],
              ),
            ),
          );

          expect(find.byType(ListTile), findsNWidgets(2));
          expect(find.text('Engine speed'), findsOneWidget);
          expect(find.text('Current gear'), findsOneWidget);
        });

    testWidgets('handles an empty signal list',
            (tester) async {
          await tester.pumpWidget(
            wrap(
              const CanSignalList(signals: []),
            ),
          );

          expect(find.byType(ListTile), findsNothing);
          expect(tester.takeException(), isNull);
        });

    testWidgets('updates displayed signal values',
            (tester) async {
          await tester.pumpWidget(
            wrap(
              const CanSignalList(signals: [engineSpeed]),
            ),
          );

          expect(find.text('1244.125 rpm'), findsOneWidget);

          const updatedSignal = SignalDisplayData(
            tag: 'engine_speed',
            name: 'Engine speed',
            value: '1500',
            unit: 'rpm',
          );

          await tester.pumpWidget(
            wrap(
              const CanSignalList(signals: [updatedSignal]),
            ),
          );

          expect(find.text('1500 rpm'), findsOneWidget);
          expect(find.text('1244.125 rpm'), findsNothing);
        });

    testWidgets('supports scrolling through many signals',
            (tester) async {
          final signals = List.generate(
            50,
                (index) => SignalDisplayData(
              tag: 'signal_$index',
              name: 'Signal $index',
              value: '$index',
              unit: 'rpm',
            ),
          );

          await tester.pumpWidget(
            wrap(CanSignalList(signals: signals)),
          );

          expect(find.text('Signal 0'), findsOneWidget);
          expect(find.text('Signal 49'), findsNothing);

          await tester.scrollUntilVisible(
            find.text('Signal 49'),
            300,
            scrollable: find.byType(Scrollable),
          );

          expect(find.text('Signal 49'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
  });
}
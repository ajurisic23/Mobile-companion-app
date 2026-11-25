import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:can_core/can_core.dart';
import 'package:can_gauge/can_gauge.dart';
import 'package:can_gauge/widgets/can_signal_gauge.dart';
import 'package:can_gauge/widgets/can_signal_gauge_grid.dart';

void main() {
  const fuelLevel = SignalDisplayData(
    tag: 'fuel_level',
    name: 'Fuel level',
    value: '61.2',
    unit: '%',
  );

  const engineSpeed = SignalDisplayData(
    tag: 'engine_speed',
    name: 'Engine speed',
    value: '1500',
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

  Finder progressIndicator(double value) {
    return find.byWidgetPredicate(
          (widget) =>
      widget is CircularProgressIndicator &&
          widget.strokeCap == StrokeCap.round &&
          widget.value != null &&
          (widget.value! - value).abs() < 0.0001,
    );
  }

  group('CanGaugeView', () {
    test('provides correct module metadata', () {
      const view = CanGaugeView();

      expect(view.id, 'gauge');
      expect(view.label, 'Gauge');
      expect(view.icon, Icons.speed);
    });

    test('implements the shared CanSignalView interface', () {
      expect(const CanGaugeView(), isA<CanSignalView>());
    });

    test('builds a CanSignalGaugeGrid', () {
      const view = CanGaugeView();

      final widget = view.buildView([fuelLevel]);

      expect(widget, isA<CanSignalGaugeGrid>());
    });
  });

  group('CanSignalGauge', () {
    testWidgets('displays signal name, value, unit and range',
            (tester) async {
          await tester.pumpWidget(
            wrap(const CanSignalGauge(signal: fuelLevel)),
          );

          expect(find.text('Fuel level'), findsOneWidget);
          expect(find.text('61.2'), findsOneWidget);
          expect(find.text('%'), findsOneWidget);
          expect(find.text('0 – 100 %'), findsOneWidget);
        });

    testWidgets('displays correct percentage progress',
            (tester) async {
          await tester.pumpWidget(
            wrap(const CanSignalGauge(signal: fuelLevel)),
          );

          expect(
            find.byType(CircularProgressIndicator),
            findsNWidgets(2),
          );

          expect(progressIndicator(0.612), findsOneWidget);
        });

    testWidgets('displays correct engine speed progress',
            (tester) async {
          await tester.pumpWidget(
            wrap(const CanSignalGauge(signal: engineSpeed)),
          );

          expect(progressIndicator(0.5), findsOneWidget);
          expect(find.text('0 – 3000 rpm'), findsOneWidget);
        });

    testWidgets('rounds decimal values to two decimal places',
            (tester) async {
          const signal = SignalDisplayData(
            tag: 'fuel_pressure',
            name: 'Fuel pressure',
            value: '564.3000000000001',
            unit: 'kPa',
          );

          await tester.pumpWidget(
            wrap(const CanSignalGauge(signal: signal)),
          );

          expect(find.text('564.3'), findsOneWidget);
          expect(
            find.text('564.3000000000001'),
            findsNothing,
          );
        });

    testWidgets('displays negative temperature values',
            (tester) async {
          const signal = SignalDisplayData(
            tag: 'coolant_temperature',
            name: 'Coolant temperature',
            value: '-15.5',
            unit: 'degC',
          );

          await tester.pumpWidget(
            wrap(const CanSignalGauge(signal: signal)),
          );

          expect(find.text('-15.5'), findsOneWidget);
          expect(find.text('-40 – 150 degC'), findsOneWidget);
          expect(
            progressIndicator(24.5 / 190),
            findsOneWidget,
          );
        });

    testWidgets('clamps values above the display range',
            (tester) async {
          const signal = SignalDisplayData(
            tag: 'fuel_level',
            name: 'Fuel level',
            value: '120',
            unit: '%',
          );

          await tester.pumpWidget(
            wrap(const CanSignalGauge(signal: signal)),
          );

          expect(find.text('120'), findsOneWidget);
          expect(progressIndicator(1.0), findsOneWidget);
          expect(
            find.text('Outside display range'),
            findsOneWidget,
          );
        });

    testWidgets('clamps values below the display range',
            (tester) async {
          const signal = SignalDisplayData(
            tag: 'fuel_level',
            name: 'Fuel level',
            value: '-10',
            unit: '%',
          );

          await tester.pumpWidget(
            wrap(const CanSignalGauge(signal: signal)),
          );

          expect(find.text('-10'), findsOneWidget);
          expect(progressIndicator(0.0), findsOneWidget);
          expect(
            find.text('Outside display range'),
            findsOneWidget,
          );
        });

    testWidgets('displays unitless signals without progress',
            (tester) async {
          await tester.pumpWidget(
            wrap(const CanSignalGauge(signal: currentGear)),
          );

          expect(find.text('Current gear'), findsOneWidget);
          expect(find.text('3'), findsOneWidget);
          expect(find.text('Unitless value'), findsOneWidget);
          expect(find.byIcon(Icons.numbers), findsOneWidget);
          expect(
            find.byType(CircularProgressIndicator),
            findsNothing,
          );
        });

    testWidgets('displays cumulative values without progress',
            (tester) async {
          const signal = SignalDisplayData(
            tag: 'engine_total_hours',
            name: 'Engine total hours',
            value: '1404.1',
            unit: 'h',
          );

          await tester.pumpWidget(
            wrap(const CanSignalGauge(signal: signal)),
          );

          expect(find.text('1404.1'), findsOneWidget);
          expect(find.text('h'), findsOneWidget);
          expect(find.text('Numeric value'), findsOneWidget);
          expect(
            find.byType(CircularProgressIndicator),
            findsNothing,
          );
        });

    for (final rawValue in ['N/A', 'NaN', 'Infinity']) {
      testWidgets('handles invalid numeric value: $rawValue',
              (tester) async {
            final signal = SignalDisplayData(
              tag: 'fuel_level',
              name: 'Fuel level',
              value: rawValue,
              unit: '%',
            );

            await tester.pumpWidget(
              wrap(CanSignalGauge(signal: signal)),
            );

            expect(find.text(rawValue), findsOneWidget);
            expect(find.text('Numeric value'), findsOneWidget);
            expect(
              find.byType(CircularProgressIndicator),
              findsNothing,
            );
            expect(tester.takeException(), isNull);
          });
    }
  });

  group('CanSignalGaugeGrid', () {
    testWidgets('displays multiple CAN signals',
            (tester) async {
          await tester.pumpWidget(
            wrap(
              const CanSignalGaugeGrid(
                signals: [fuelLevel, engineSpeed, currentGear],
              ),
            ),
          );

          expect(
            find.byType(CanSignalGauge),
            findsNWidgets(3),
          );

          expect(find.text('Fuel level'), findsOneWidget);
          expect(find.text('Engine speed'), findsOneWidget);
          expect(find.text('Current gear'), findsOneWidget);
        });

    testWidgets('handles an empty signal list',
            (tester) async {
          await tester.pumpWidget(
            wrap(const CanSignalGaugeGrid(signals: [])),
          );

          expect(find.byType(CanSignalGauge), findsNothing);
          expect(tester.takeException(), isNull);
        });

    testWidgets('updates displayed values and progress',
            (tester) async {
          await tester.pumpWidget(
            wrap(
              const CanSignalGaugeGrid(signals: [fuelLevel]),
            ),
          );

          expect(find.text('61.2'), findsOneWidget);
          expect(progressIndicator(0.612), findsOneWidget);

          const updatedSignal = SignalDisplayData(
            tag: 'fuel_level',
            name: 'Fuel level',
            value: '80',
            unit: '%',
          );

          await tester.pumpWidget(
            wrap(
              const CanSignalGaugeGrid(
                signals: [updatedSignal],
              ),
            ),
          );

          expect(find.text('80'), findsOneWidget);
          expect(find.text('61.2'), findsNothing);
          expect(progressIndicator(0.8), findsOneWidget);
        });

    testWidgets('handles a narrow mobile screen',
            (tester) async {
          await tester.binding.setSurfaceSize(
            const Size(360, 640),
          );

          addTearDown(
                () => tester.binding.setSurfaceSize(null),
          );

          const signal = SignalDisplayData(
            tag: 'fuel_pressure',
            name: 'Engine fuel delivery pressure',
            value: '564.3000000000001',
            unit: 'kPa',
          );

          await tester.pumpWidget(
            wrap(
              const CanSignalGaugeGrid(
                signals: [signal, engineSpeed],
              ),
            ),
          );

          expect(find.text('564.3'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
  });
}
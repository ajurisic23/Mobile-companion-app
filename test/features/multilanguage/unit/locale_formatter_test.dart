import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_companion_app/features/multilanguage/date_format/locale_formatter.dart';

class _LocaleTestHost extends StatelessWidget {
  const _LocaleTestHost({
    required this.locale,
    required this.builder,
  });

  final Locale locale;
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      supportedLocales: const [
        Locale('de'),
        Locale('hr'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Builder(builder: builder),
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  final sampleDateTime = DateTime(2026, 11, 25, 14, 30);

  testWidgets(
    '1. Njemački: 25.11.2026. 14:30 -> datum "25.11.2026" i vrijeme "14:30"',
        (tester) async {
      String? formattedDate;
      String? formattedTime;

      await tester.pumpWidget(
        _LocaleTestHost(
          locale: const Locale('de'),
          builder: (context) {
            formattedDate = LocaleFormatter.formatDate(context, sampleDateTime);
            formattedTime = LocaleFormatter.formatTime(context, sampleDateTime);
            return Column(
              children: [
                Text(formattedDate!),
                Text(formattedTime!),
              ],
            );
          },
        ),
      );

      expect(formattedDate, '25.11.2026');
      expect(formattedTime, '14:30');
      expect(find.text('25.11.2026'), findsOneWidget);
      expect(find.text('14:30'), findsOneWidget);
    },
  );

  testWidgets(
    '4. Temperatura 85.5 °C prikazuje se kao "85.5 °C" na engleskom i "85,5 °C" na njemačkom',
        (tester) async {
      final localeNotifier = ValueNotifier<Locale>(const Locale('en'));

      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, currentLocale, _) {
            return _LocaleTestHost(
              locale: currentLocale,
              builder: (context) {
                final formattedTemp = LocaleFormatter.formatTemperature(context, 85.5);
                return Text(formattedTemp);
              },
            );
          },
        ),
      );

      expect(find.text('85.5 °C'), findsOneWidget);

      localeNotifier.value = const Locale('de');
      await tester.pumpAndSettle();

      expect(find.text('85,5 °C'), findsOneWidget);
    },
  );



}


import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class LocaleFormatter {
  LocaleFormatter._();

  static String _localeName(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.countryCode != null && locale.countryCode!.isNotEmpty
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
  }

  static String formatDate(BuildContext context, DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateFormat.yMd(_localeName(context)).format(local);
  }

  static String formatTime(BuildContext context, DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateFormat.Hm(_localeName(context)).format(local);
  }
  static String formatTemperature(BuildContext context, double celsius) {
    final localeName = _localeName(context);
    final formattedNumber = NumberFormat('0.0', localeName).format(celsius);
    return '$formattedNumber °C';
  }

}
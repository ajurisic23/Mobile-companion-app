import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/features/multilanguage/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';



Future<LocaleController> createController({
  Map<String, Object> saved = const {},
  String deviceLanguage = 'en',
}) async {
  SharedPreferences.setMockInitialValues(saved);
  final prefs = await SharedPreferences.getInstance();

  return LocaleController(
    prefs: prefs,
    deviceLocale: Locale(deviceLanguage),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('uses German when the device language is German', () async {
    final controller = await createController(deviceLanguage: 'de');

    expect(controller.locale.languageCode, 'de');
  });

  test('uses English for any other device language', () async {
    final controller = await createController(deviceLanguage: 'fr');

    expect(controller.locale.languageCode, 'en');
  });

}
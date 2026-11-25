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

  test('uses the saved language over the device language', () async {
    final controller = await createController(
      saved: {'app_language': 'de'},
    );

    expect(controller.locale.languageCode, 'de');
  });
  test('setLocale changes the language and notifies listeners', () async {
    final controller = await createController();
    int calls = 0;

    controller.addListener(() => calls++);

    await controller.setLocale(const Locale('de'));

    expect(controller.locale.languageCode, 'de');
    expect(calls, 1);
  });
  test('setLocale saves the choice', () async {
    final controller = await createController();
    await controller.setLocale(const Locale('de'));

    final newController = LocaleController(
      prefs: await SharedPreferences.getInstance(),
      deviceLocale: const Locale('en'),
    );

    expect(newController.locale.languageCode, 'de');
  });
  test('setLocale ignores an unsupported language', () async {
    final controller = await createController();

    await controller.setLocale(const Locale('fr'));

    expect(controller.locale.languageCode, 'en');
  });
}
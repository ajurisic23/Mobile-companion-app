import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @connectToGateway.
  ///
  /// In en, this message translates to:
  /// **'Connect to a CAN gateway'**
  String get connectToGateway;

  /// No description provided for @simulatedData.
  ///
  /// In en, this message translates to:
  /// **'Simulated data'**
  String get simulatedData;

  /// No description provided for @simulatedDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'continue without connecting to a real device'**
  String get simulatedDataSubtitle;

  /// No description provided for @gatewayAddress.
  ///
  /// In en, this message translates to:
  /// **'Gateway address'**
  String get gatewayAddress;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @savedGateways.
  ///
  /// In en, this message translates to:
  /// **'Saved gateways'**
  String get savedGateways;

  /// No description provided for @deleteGateway.
  ///
  /// In en, this message translates to:
  /// **'Delete gateway?'**
  String get deleteGateway;

  /// No description provided for @deleteGatewayConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the saved gateway {address}?'**
  String deleteGatewayConfirmation(String address);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @gatewayAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the gateway address.'**
  String get gatewayAddressRequired;

  /// No description provided for @gatewayAddressWithoutPath.
  ///
  /// In en, this message translates to:
  /// **'Enter only the address, without http:// or a path.'**
  String get gatewayAddressWithoutPath;

  /// No description provided for @gatewayAddressWithoutPort.
  ///
  /// In en, this message translates to:
  /// **'Enter the port in the Port field, not in the address.'**
  String get gatewayAddressWithoutPort;

  /// No description provided for @gatewayAddressWithoutSpaces.
  ///
  /// In en, this message translates to:
  /// **'The address must not contain spaces.'**
  String get gatewayAddressWithoutSpaces;

  /// No description provided for @invalidIpAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid IP address. Expected format: 192.168.0.100.'**
  String get invalidIpAddress;

  /// No description provided for @invalidHostName.
  ///
  /// In en, this message translates to:
  /// **'Invalid host name.'**
  String get invalidHostName;

  /// No description provided for @portMustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'Port must be a number.'**
  String get portMustBeNumber;

  /// No description provided for @invalidPortRange.
  ///
  /// In en, this message translates to:
  /// **'Port must be between 1 and 65535.'**
  String get invalidPortRange;

  /// No description provided for @connectionRefused.
  ///
  /// In en, this message translates to:
  /// **'The device refused the connection. Check the port number.'**
  String get connectionRefused;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'The gateway did not respond in time. Check that you are close enough and connected to the gateway Wi-Fi, then try again.'**
  String get connectionTimeout;

  /// No description provided for @connectionNetworkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the gateway. Check that your phone is connected to the gateway Wi-Fi network.'**
  String get connectionNetworkUnavailable;

  /// No description provided for @connectionUnknownHost.
  ///
  /// In en, this message translates to:
  /// **'The address was not found. Check that it is typed correctly.'**
  String get connectionUnknownHost;

  /// No description provided for @connectionNotGateway.
  ///
  /// In en, this message translates to:
  /// **'The device responded, but it does not look like a CAN gateway. Check the address and port.'**
  String get connectionNotGateway;

  /// No description provided for @connectionBadStatus.
  ///
  /// In en, this message translates to:
  /// **'The device responded with an unexpected status{status}. Check the address and port.'**
  String connectionBadStatus(String status);

  /// No description provided for @connectionInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The device responded, but the response was not understood. Check that this is a CAN gateway.'**
  String get connectionInvalidResponse;

  /// No description provided for @connectionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The gateway is not available. Check the address and port, then try again.'**
  String get connectionUnavailable;

  /// No description provided for @connectionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while connecting. Please try again.'**
  String get connectionUnknown;

  /// No description provided for @connectToSeePorts.
  ///
  /// In en, this message translates to:
  /// **'Connect to a gateway to see its CAN ports.'**
  String get connectToSeePorts;

  /// No description provided for @loadingCanPorts.
  ///
  /// In en, this message translates to:
  /// **'Loading CAN ports...'**
  String get loadingCanPorts;

  /// No description provided for @noCanPorts.
  ///
  /// In en, this message translates to:
  /// **'This gateway has no CAN ports available.'**
  String get noCanPorts;

  /// No description provided for @canPort.
  ///
  /// In en, this message translates to:
  /// **'CAN port'**
  String get canPort;

  /// No description provided for @selectCanPort.
  ///
  /// In en, this message translates to:
  /// **'Select a CAN port'**
  String get selectCanPort;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'disabled'**
  String get disabled;

  /// No description provided for @canPortCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 port} other{{count} ports}}'**
  String canPortCount(int count);

  /// No description provided for @canPortsTimeout.
  ///
  /// In en, this message translates to:
  /// **'The gateway did not respond in time. Check the connection and try again.'**
  String get canPortsTimeout;

  /// No description provided for @canPortsNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the gateway. Check that you are on the same network.'**
  String get canPortsNetwork;

  /// No description provided for @canPortsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The gateway could not provide the CAN ports.'**
  String get canPortsUnavailable;

  /// No description provided for @canPortsInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The gateway returned an unexpected response.'**
  String get canPortsInvalidResponse;

  /// No description provided for @canPortsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Could not load the CAN ports.'**
  String get canPortsUnknown;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

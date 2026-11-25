// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get connectToGateway => 'Mit einem CAN-Gateway verbinden';

  @override
  String get simulatedData => 'Simulierte Daten';

  @override
  String get simulatedDataSubtitle =>
      'Ohne Verbindung zu einem echten Gerät fortfahren';

  @override
  String get gatewayAddress => 'Gateway-Adresse';

  @override
  String get port => 'Port';

  @override
  String get optional => 'optional';

  @override
  String get connect => 'Verbinden';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get savedGateways => 'Gespeicherte Gateways';

  @override
  String get deleteGateway => 'Gateway löschen';

  @override
  String deleteGatewayConfirmation(String address) {
    return 'Möchten Sie das gespeicherte Gateway $address wirklich löschen?';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get gatewayAddressRequired => 'Gateway-Adresse ist erforderlich';

  @override
  String get gatewayAddressWithoutPath =>
      'Geben Sie nur die Adresse ohne http:// oder Pfad ein.';

  @override
  String get gatewayAddressWithoutPort =>
      'Geben Sie den Port im Port-Feld ein.';

  @override
  String get gatewayAddressWithoutSpaces =>
      'Die Adresse darf keine Leerzeichen enthalten.';

  @override
  String get invalidIpAddress =>
      'Ungültige IP-Adresse. Erwartetes Format: 192.168.0.100.';

  @override
  String get invalidHostName => 'Ungültiger Hostname.';

  @override
  String get portMustBeNumber => 'Der Port muss eine Zahl sein.';

  @override
  String get invalidPortRange => 'Der Port muss zwischen 1 und 65535 liegen';

  @override
  String get connectionRefused =>
      'Das Gerät hat die Verbindung abgelehnt. Überprüfen Sie die Portnummer.';

  @override
  String get connectionTimeout =>
      'Das Gateway hat nicht rechtzeitig geantwortet. Überprüfen Sie die WLAN-Verbindung und versuchen Sie es erneut.';

  @override
  String get connectionNetworkUnavailable =>
      'Das Gateway konnte nicht erreicht werden. Überprüfen Sie die WLAN-Verbindung.';

  @override
  String get connectionUnknownHost =>
      'Die Adresse wurde nicht gefunden. Überprüfen Sie die Eingabe.';

  @override
  String get connectionNotGateway =>
      'Das Gerät scheint kein CAN-Gateway zu sein. Überprüfen Sie die Adresse und den Port.';

  @override
  String connectionBadStatus(String status) {
    return 'Das Gerät hat mit einem unerwarteten Status$status geantwortet. Überprüfen Sie die Adresse und den Port.';
  }

  @override
  String get connectionInvalidResponse =>
      'Die Antwort des Geräts konnte nicht verarbeitet werden. Überprüfen Sie, ob es sich um ein CAN-Gateway handelt.';

  @override
  String get connectionUnavailable =>
      'Das Gateway ist nicht verfügbar. Überprüfen Sie die Adresse und den Port und versuchen Sie es erneut.';

  @override
  String get connectionUnknown =>
      'Beim Verbinden ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get connectToSeePorts =>
      'Verbinden Sie sich mit einem Gateway, um dessen CAN-Ports anzuzeigen.';

  @override
  String get loadingCanPorts => 'CAN-Ports werden geladen...';

  @override
  String get noCanPorts => 'Dieses Gateway hat keine verfügbaren CAN-Ports.';

  @override
  String get canPort => 'CAN-Port';

  @override
  String get selectCanPort => 'CAN-Port auswählen';

  @override
  String get disabled => 'deaktiviert';

  @override
  String canPortCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ports',
      one: '1 Port',
    );
    return '$_temp0';
  }

  @override
  String get canPortsTimeout =>
      'Das Gateway hat nicht rechtzeitig geantwortet. Überprüfen Sie die Verbindung und versuchen Sie es erneut.';

  @override
  String get canPortsNetwork =>
      'Das Gateway konnte nicht erreicht werden. Überprüfen Sie, ob Sie sich im selben Netzwerk befinden.';

  @override
  String get canPortsUnavailable =>
      'Das Gateway konnte die CAN-Ports nicht bereitstellen.';

  @override
  String get canPortsInvalidResponse =>
      'Das Gateway hat eine unerwartete Antwort zurückgegeben.';

  @override
  String get canPortsUnknown => 'Die CAN-Ports konnten nicht geladen werden.';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';
}

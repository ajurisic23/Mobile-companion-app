// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get connectToGateway => 'Connect to a CAN gateway';

  @override
  String get simulatedData => 'Simulated data';

  @override
  String get simulatedDataSubtitle =>
      'continue without connecting to a real device';

  @override
  String get gatewayAddress => 'Gateway address';

  @override
  String get port => 'Port';

  @override
  String get optional => 'optional';

  @override
  String get connect => 'Connect';

  @override
  String get tryAgain => 'Try again';

  @override
  String get savedGateways => 'Saved gateways';

  @override
  String get deleteGateway => 'Delete gateway?';

  @override
  String deleteGatewayConfirmation(String address) {
    return 'Are you sure you want to delete the saved gateway $address?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get gatewayAddressRequired => 'Enter the gateway address.';

  @override
  String get gatewayAddressWithoutPath =>
      'Enter only the address, without http:// or a path.';

  @override
  String get gatewayAddressWithoutPort =>
      'Enter the port in the Port field, not in the address.';

  @override
  String get gatewayAddressWithoutSpaces =>
      'The address must not contain spaces.';

  @override
  String get invalidIpAddress =>
      'Invalid IP address. Expected format: 192.168.0.100.';

  @override
  String get invalidHostName => 'Invalid host name.';

  @override
  String get portMustBeNumber => 'Port must be a number.';

  @override
  String get invalidPortRange => 'Port must be between 1 and 65535.';

  @override
  String get connectionRefused =>
      'The device refused the connection. Check the port number.';

  @override
  String get connectionTimeout =>
      'The gateway did not respond in time. Check that you are close enough and connected to the gateway Wi-Fi, then try again.';

  @override
  String get connectionNetworkUnavailable =>
      'Cannot reach the gateway. Check that your phone is connected to the gateway Wi-Fi network.';

  @override
  String get connectionUnknownHost =>
      'The address was not found. Check that it is typed correctly.';

  @override
  String get connectionNotGateway =>
      'The device responded, but it does not look like a CAN gateway. Check the address and port.';

  @override
  String connectionBadStatus(String status) {
    return 'The device responded with an unexpected status$status. Check the address and port.';
  }

  @override
  String get connectionInvalidResponse =>
      'The device responded, but the response was not understood. Check that this is a CAN gateway.';

  @override
  String get connectionUnavailable =>
      'The gateway is not available. Check the address and port, then try again.';

  @override
  String get connectionUnknown =>
      'Something went wrong while connecting. Please try again.';

  @override
  String get connectToSeePorts => 'Connect to a gateway to see its CAN ports.';

  @override
  String get loadingCanPorts => 'Loading CAN ports...';

  @override
  String get noCanPorts => 'This gateway has no CAN ports available.';

  @override
  String get canPort => 'CAN port';

  @override
  String get selectCanPort => 'Select a CAN port';

  @override
  String get disabled => 'disabled';

  @override
  String canPortCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ports',
      one: '1 port',
    );
    return '$_temp0';
  }

  @override
  String get canPortsTimeout =>
      'The gateway did not respond in time. Check the connection and try again.';

  @override
  String get canPortsNetwork =>
      'Could not reach the gateway. Check that you are on the same network.';

  @override
  String get canPortsUnavailable =>
      'The gateway could not provide the CAN ports.';

  @override
  String get canPortsInvalidResponse =>
      'The gateway returned an unexpected response.';

  @override
  String get canPortsUnknown => 'Could not load the CAN ports.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get german => 'Deutsch';
}

import 'package:mobile_companion_app/l10n/app_localizations.dart';

final _ipv4Candidate = RegExp(r'^[0-9.]+$');
final _digitsOnly = RegExp(r'^\d+$');
final _hostnameRegex = RegExp(
  r'^[a-zA-Z0-9](?:[a-zA-Z0-9.-]*[a-zA-Z0-9])?$',
);

String? validateGatewayHost(
    String? value, {
      AppLocalizations? l10n,
    }) {
  final host = (value ?? '').trim();

  if (host.isEmpty) {
    return l10n?.gatewayAddressRequired ??
        'Enter the gateway address.';
  }

  if (host.contains('://') || host.contains('/')) {
    return l10n?.gatewayAddressWithoutPath ??
        'Enter only the address, without http:// or a path.';
  }

  if (host.contains(':')) {
    return l10n?.gatewayAddressWithoutPort ??
        'Enter the port in the Port field, not in the address.';
  }

  if (host.contains(RegExp(r'\s'))) {
    return l10n?.gatewayAddressWithoutSpaces ??
        'The address must not contain spaces.';
  }

  if (_ipv4Candidate.hasMatch(host)) {
    final parts = host.split('.');

    final isValid = parts.length == 4 &&
        parts.every((part) {
          final number = int.tryParse(part);

          return number != null &&
              number >= 0 &&
              number <= 255;
        });

    if (!isValid) {
      return l10n?.invalidIpAddress ??
          'Invalid IP address. Expected format: 192.168.0.100.';
    }

    return null;
  }

  if (!_hostnameRegex.hasMatch(host)) {
    return l10n?.invalidHostName ??
        'Invalid host name.';
  }

  return null;
}

String? validateGatewayPort(
    String? value, {
      AppLocalizations? l10n,
    }) {
  final port = (value ?? '').trim();

  if (port.isEmpty) {
    return null;
  }

  if (!_digitsOnly.hasMatch(port)) {
    return l10n?.portMustBeNumber ??
        'Port must be a number.';
  }

  final number = int.tryParse(port);

  if (number == null || number < 1 || number > 65535) {
    return l10n?.invalidPortRange ??
        'Port must be between 1 and 65535.';
  }

  return null;
}
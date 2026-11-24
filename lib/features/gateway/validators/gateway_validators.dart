final _ipv4Candidate = RegExp(r'^[0-9.]+$');
final _digitsOnly = RegExp(r'^[0-9]+$');
final _hostnameRegex = RegExp(
  r'^(?=.{1,253}$)([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)'
  r'(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
);

String? validateGatewayHost(String? value) {
  final host = value?.trim() ?? '';

  if (host.isEmpty) return 'Enter the gateway address.';

  if (host.contains('://') || host.contains('/')) {
    return 'Enter only the address, without http:// or a path.';
  }

  if (host.contains(':')) {
    return 'Enter the port in the Port field, not in the address.';
  }

  if (host.contains(' ')) {
    return 'The address must not contain spaces.';
  }

  if (_ipv4Candidate.hasMatch(host)) {
    final parts = host.split('.');
    final isValid = parts.length == 4 &&
        parts.every((part) {
          final number = int.tryParse(part);
          return part.isNotEmpty && number != null && number <= 255;
        });
    return isValid
        ? null
        : 'Invalid IP address. Expected format: 192.168.0.100.';
  }

  if (!_hostnameRegex.hasMatch(host)) return 'Invalid host name.';

  return null;
}

String? validateGatewayPort(String? value) {
  final text = value?.trim() ?? '';

  if (text.isEmpty) return null;
  if (!_digitsOnly.hasMatch(text)) return 'Port must be a number.';

  final port = int.tryParse(text);
  if (port == null || port < 1 || port > 65535) {
    return 'Port must be between 1 and 65535.';
  }

  return null;
}
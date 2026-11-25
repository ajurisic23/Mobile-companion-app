import '../../../l10n/app_localizations.dart';
import '../models/connection_failure.dart';
import '../services/can_ports_service.dart';

extension ConnectionFailureLocalization on ConnectionFailure {
  String localizedMessage(AppLocalizations l10n) {
    switch (type) {
      case ConnectionFailureType.timeout:
        return l10n.connectionTimeout;

      case ConnectionFailureType.networkUnavailable:
        return l10n.connectionNetworkUnavailable;

      case ConnectionFailureType.connectionRefused:
        return l10n.connectionRefused;

      case ConnectionFailureType.unknownHost:
        return l10n.connectionUnknownHost;

      case ConnectionFailureType.badStatus:
        if (statusCode == 404) {
          return l10n.connectionNotGateway;
        }

        return l10n.connectionBadStatus(
          statusCode == null ? '' : ' ($statusCode)',
        );

      case ConnectionFailureType.invalidResponse:
        return l10n.connectionInvalidResponse;

      case ConnectionFailureType.unavailable:
        return l10n.connectionUnavailable;

      case ConnectionFailureType.unknown:
        return l10n.connectionUnknown;
    }
  }
}

extension CanPortsFailureLocalization on CanPortsException {
  String localizedMessage(AppLocalizations l10n) {
    switch (type) {
      case CanPortsFailureType.timeout:
        return l10n.canPortsTimeout;

      case CanPortsFailureType.network:
        return l10n.canPortsNetwork;

      case CanPortsFailureType.unavailable:
        return l10n.canPortsUnavailable;

      case CanPortsFailureType.invalidResponse:
        return l10n.canPortsInvalidResponse;
    }
  }
}
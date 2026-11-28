enum NetworkFailureType { timeout, network, badStatus, invalidResponse }

/// Represents a standardized network failure while preserving
/// the HTTP status code and original cause when available.
class NetworkException implements Exception {
  const NetworkException(this.type, {this.statusCode, this.cause});

  final NetworkFailureType type;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() {
    return 'NetworkException('
        'type: $type, '
        'statusCode: $statusCode, '
        'cause: $cause)';
  }
}

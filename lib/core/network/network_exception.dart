enum NetworkFailureType { timeout, network, badStatus, invalidResponse }

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

/// Defines shared default configuration for network communication.
class NetworkConfig {
  NetworkConfig._();

  static const Duration requestTimeout = Duration(seconds: 5);

  static const String httpScheme = 'http';
}

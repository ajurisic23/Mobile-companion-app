import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'network_config.dart';
import 'network_exception.dart';

/// Reusable HTTP client that centralizes request execution,
/// timeouts, HTTP status validation and network error handling.
///
/// Request bodies and content-type headers are managed by the caller.
class ApiClient {
  /// Creates and owns an HTTP client unless an external client is provided.
  ApiClient({http.Client? client, this.timeout = NetworkConfig.requestTimeout})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  static Uri buildUri({
    required String host,
    required int port,
    required String path,
    String scheme = NetworkConfig.httpScheme,
    Map<String, String>? queryParameters,
  }) {
    return Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: path,
      queryParameters: queryParameters,
    );
  }

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    return _execute(() => _client.get(uri, headers: headers));
  }

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _execute(() => _client.post(uri, headers: headers, body: body));
  }

  Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _execute(() => _client.put(uri, headers: headers, body: body));
  }

  Future<http.Response> patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _execute(() => _client.patch(uri, headers: headers, body: body));
  }

  Future<http.Response> delete(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _execute(() => _client.delete(uri, headers: headers, body: body));
  }

  /// Decodes the response body and converts malformed JSON into a
  /// standardized network exception.
  ///
  /// Validation of the decoded data structure is the caller's responsibility.
  static dynamic decodeJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException catch (error) {
      throw NetworkException(NetworkFailureType.invalidResponse, cause: error);
    }
  }

  /// Executes a request with the configured timeout and accepts only
  /// successful HTTP status codes (2xx).
  ///
  /// A timeout does not guarantee cancellation of the underlying request.
  Future<http.Response> _execute(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NetworkException(
          NetworkFailureType.badStatus,
          statusCode: response.statusCode,
        );
      }

      return response;
    } on TimeoutException catch (error) {
      throw NetworkException(NetworkFailureType.timeout, cause: error);
    } on SocketException catch (error) {
      throw NetworkException(NetworkFailureType.network, cause: error);
    } on http.ClientException catch (error) {
      throw NetworkException(NetworkFailureType.network, cause: error);
    }
  }

  /// Releases the HTTP client only if it is owned by this instance.
  /// Externally provided clients remain the caller's responsibility.
  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}

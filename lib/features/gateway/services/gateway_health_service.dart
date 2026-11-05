
import 'package:http/http.dart' as http;

class GatewayHealthService {
  final http.Client client;

  GatewayHealthService({http.Client? client})
      : client = client ?? http.Client();

  Future<bool> checkHealth({
    required String address,
    required int port,
  }) async {
    final uri = Uri(
      scheme: 'http',
      host: address,
      port: port,
      path: '/api/v1/health',
    );

    try {
      final response = await client.get(uri).timeout(
        const Duration(seconds: 5),
      );

      return response.statusCode >= 200 &&
          response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gateway_health_model.dart';

class GatewayService {
  final String baseUrl = 'http://192.168.0.100:10000';

  Future<GatewayHealthModel> fetchGatewayHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/v1/health'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return GatewayHealthModel.fromJson(jsonData);
      }
      else {
        throw Exception('Greška na serveru: ${response.statusCode}');
      }
    }
    catch (e) {
      throw Exception('Neuspjelo spajanje na gateway: $e');
    }
  }
}
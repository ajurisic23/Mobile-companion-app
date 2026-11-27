import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_companion_app/core/network/network_config.dart';

void main() {
  group('NetworkConfig', () {
    test('uses a default request timeout of five seconds', () {
      expect(NetworkConfig.requestTimeout, const Duration(seconds: 5));
    });

    test('uses HTTP as the default scheme', () {
      expect(NetworkConfig.httpScheme, 'http');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:network_service/base_api_service.dart';
import 'package:network_service/util/constants.dart';

void main() {
  test('ApiService creates the Dio client without forcing Alice early', () {
    final service = ApiService();

    expect(service.isInitialized, isFalse);
    expect(() => service.alice, throwsStateError);
    expect(service.aliceNavigatorKey, isNull);
    expect(service.apiClient.options.baseUrl, isNotNull);
    expect(service.apiClient.options.baseUrl, Constants.BASE_URL);
  });
}

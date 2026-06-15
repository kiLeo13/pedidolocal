import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/token_storage.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:pedidolocal/repositories/auth_repository.dart';

import 'test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('auth provider stores token on login and clears it on logout', () async {
    final storage = const TokenStorage();
    final apiClient = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/auth/token') {
          expect(request.bodyFields['username'], 'customer@example.com');
          return http.Response(
            jsonEncode({
              'access_token': 'stored-token',
              'token_type': 'bearer',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/auth/me') {
          expect(request.headers['authorization'], 'Bearer stored-token');
          return http.Response(
            jsonEncode(userJson()),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('not found', 404);
      }),
    );
    final provider = AuthProvider(
      repository: AuthRepository(apiClient: apiClient, tokenStorage: storage),
    );

    await provider.login('customer@example.com', 'Customer123');

    expect(provider.isAuthenticated, isTrue);
    expect(provider.currentUser?.fullName, 'Cliente Teste');
    expect(
      await const FlutterSecureStorage().read(
        key: AppConstants.tokenStorageKey,
      ),
      'stored-token',
    );

    await provider.logout();

    expect(provider.isAuthenticated, isFalse);
    expect(
      await const FlutterSecureStorage().read(
        key: AppConstants.tokenStorageKey,
      ),
      isNull,
    );
  });
}

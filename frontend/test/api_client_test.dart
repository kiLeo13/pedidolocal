import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/core/api/api_exceptions.dart';

void main() {
  test('postForm sends form-encoded credentials', () async {
    final client = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'http://api.test/auth/token');
        expect(
          request.headers['content-type'],
          'application/x-www-form-urlencoded',
        );
        expect(request.bodyFields, {
          'username': 'customer@example.com',
          'password': 'Customer123',
        });
        return http.Response(
          jsonEncode({'access_token': 'abc', 'token_type': 'bearer'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final data = await client.postForm(
      '/auth/token',
      fields: {'username': 'customer@example.com', 'password': 'Customer123'},
    );

    expect(data, {'access_token': 'abc', 'token_type': 'bearer'});
  });

  test('get sends bearer token when set', () async {
    final client = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer token-123');
        return http.Response('[]', 200);
      }),
    )..setToken('token-123');

    await client.get('/orders');
  });

  test('maps validation errors to ValidationException', () async {
    final client = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'detail': [
              {'msg': 'field required'},
            ],
          }),
          422,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    expect(
      () => client.post('/orders', body: {}),
      throwsA(isA<ValidationException>()),
    );
  });
}

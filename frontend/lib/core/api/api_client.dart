import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:pedidolocal/core/api/api_exceptions.dart';
import 'package:pedidolocal/core/constants.dart';

class ApiClient {
  ApiClient({String? baseUrl, http.Client? httpClient})
    : baseUrl = baseUrl ?? AppConstants.apiBaseUrl,
      _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;
  String? _authToken;

  String? get token => _authToken;

  void setToken(String? token) {
    _authToken = (token == null || token.isEmpty) ? null : token;
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final response = await _send(
      () =>
          _httpClient.get(_buildUri(path, queryParameters), headers: _headers),
    );
    return _decode(response);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await _send(
      () => _httpClient.post(
        _buildUri(path),
        headers: _headers,
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
    return _decode(response);
  }

  Future<dynamic> postForm(
    String path, {
    required Map<String, String> fields,
  }) async {
    final headers = Map<String, String>.from(_headers)
      ..['Content-Type'] = 'application/x-www-form-urlencoded';
    final response = await _send(
      () => _httpClient.post(_buildUri(path), headers: headers, body: fields),
    );
    return _decode(response);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final response = await _send(
      () => _httpClient.patch(
        _buildUri(path),
        headers: _headers,
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _send(
      () => _httpClient.delete(_buildUri(path), headers: _headers),
    );
    return _decode(response);
  }

  void dispose() {
    _httpClient.close();
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final token = _authToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, String>? queryParameters]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse(
      '$normalizedBase$path',
    ).replace(queryParameters: queryParameters);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(AppConstants.apiTimeout);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException('A requisicao expirou. Tente novamente.');
    }
  }

  dynamic _decode(http.Response response) {
    final bodyText = utf8.decode(response.bodyBytes);
    final body = bodyText.isEmpty ? null : jsonDecode(bodyText);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final detail = _extractDetail(body);
    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(detail);
      case 403:
        throw ForbiddenException(detail);
      case 404:
        throw NotFoundException(detail);
      case 409:
        throw ConflictException(detail);
      case 422:
        throw ValidationException(detail, details: _extractValidation(body));
      default:
        throw ApiException(detail, statusCode: response.statusCode);
    }
  }

  String _extractDetail(dynamic body) {
    if (body is Map<String, dynamic>) {
      final detail = body['detail'];
      if (detail is String) {
        return detail;
      }
      if (detail is List) {
        return detail
            .map((item) {
              if (item is Map<String, dynamic>) {
                return item['msg']?.toString() ?? item.toString();
              }
              return item.toString();
            })
            .where((message) => message.isNotEmpty)
            .join('; ');
      }
    }
    return 'Erro desconhecido.';
  }

  List<Map<String, dynamic>>? _extractValidation(dynamic body) {
    if (body is Map<String, dynamic> && body['detail'] is List) {
      return (body['detail'] as List).whereType<Map<String, dynamic>>().toList(
        growable: false,
      );
    }
    return null;
  }
}

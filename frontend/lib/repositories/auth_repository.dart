import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/core/api/endpoints.dart';
import 'package:pedidolocal/core/token_storage.dart';
import 'package:pedidolocal/models/token.dart';
import 'package:pedidolocal/models/user.dart';

class AuthRepository {
  const AuthRepository({required this.apiClient, required this.tokenStorage});

  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  Future<User> login({required String email, required String password}) async {
    final data = await apiClient.postForm(
      Endpoints.authToken,
      fields: {'username': email, 'password': password},
    );
    final token = TokenResponse.fromJson(data as Map<String, dynamic>);
    apiClient.setToken(token.accessToken);
    await tokenStorage.writeToken(token.accessToken);
    return currentUser();
  }

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String addressLine,
    required String city,
    String? birthDate,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'address_line': addressLine,
      'city': city,
    };
    if (birthDate != null && birthDate.isNotEmpty) {
      body['birth_date'] = birthDate;
    }
    await apiClient.post(Endpoints.authRegister, body: body);
    return login(email: email, password: password);
  }

  Future<User> currentUser() async {
    final data = await apiClient.get(Endpoints.authMe);
    return User.fromJson(data as Map<String, dynamic>);
  }

  Future<User?> restoreSession() async {
    final token = await tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      apiClient.setToken(null);
      return null;
    }
    apiClient.setToken(token);
    return currentUser();
  }

  Future<void> logout() async {
    apiClient.setToken(null);
    await tokenStorage.clearToken();
  }
}

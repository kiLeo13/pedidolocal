import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pedidolocal/core/constants.dart';

class TokenStorage {
  const TokenStorage([this._secureStorage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _secureStorage;

  Future<String?> readToken() {
    return _secureStorage.read(key: AppConstants.tokenStorageKey);
  }

  Future<void> writeToken(String token) {
    return _secureStorage.write(
      key: AppConstants.tokenStorageKey,
      value: token,
    );
  }

  Future<void> clearToken() {
    return _secureStorage.delete(key: AppConstants.tokenStorageKey);
  }
}

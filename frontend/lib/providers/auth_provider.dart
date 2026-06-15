import 'package:flutter/foundation.dart';
import 'package:pedidolocal/core/api/api_exceptions.dart';
import 'package:pedidolocal/models/user.dart';
import 'package:pedidolocal/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.repository});

  final AuthRepository repository;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> restoreSession() async {
    await _run(() async {
      _currentUser = await repository.restoreSession();
    });
  }

  Future<void> login(String email, String password) async {
    await _run(() async {
      _currentUser = await repository.login(email: email, password: password);
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String addressLine,
    required String city,
    String? birthDate,
  }) async {
    await _run(() async {
      _currentUser = await repository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        addressLine: addressLine,
        city: city,
        birthDate: birthDate,
      );
    });
  }

  Future<void> refreshCurrentUser() async {
    await _run(() async {
      _currentUser = await repository.currentUser();
    });
  }

  Future<void> logout() async {
    await repository.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } on UnauthorizedException catch (error) {
      _currentUser = null;
      _error = error.message;
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Erro inesperado. Tente novamente.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

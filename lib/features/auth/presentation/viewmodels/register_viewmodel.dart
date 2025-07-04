import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';

class RegisterViewModel with ChangeNotifier {
  final AuthProvider _authProvider;
  bool _isLoading = false;
  String? _error;

  RegisterViewModel({required AuthProvider authProvider})
    : _authProvider = authProvider;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authProvider.register(
        email: email,
        password: password,
        name: name,
      );
      return _authProvider.isAuthenticated;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

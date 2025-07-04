import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';

class LoginViewModel with ChangeNotifier {
  final AuthProvider _authProvider;
  bool _isLoading = false;
  String? _error;

  LoginViewModel({required AuthProvider authProvider})
    : _authProvider = authProvider;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('LoginViewModel: Attempting login for $email');
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authProvider.signIn(email, password);
      final isAuthenticated = _authProvider.isAuthenticated;
      debugPrint(
        'LoginViewModel: Login result - isAuthenticated: $isAuthenticated',
      );
      return isAuthenticated;
    } catch (e) {
      debugPrint('LoginViewModel: Login failed - $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('LoginViewModel: Attempting password reset for $email');
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authProvider.sendPasswordResetEmail(email);
      debugPrint('LoginViewModel: Password reset email sent');
    } catch (e) {
      debugPrint('LoginViewModel: Password reset failed - $e');
      _error = e.toString();
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

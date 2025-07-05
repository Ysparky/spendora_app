import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/auth/domain/models/user.dart';
import 'package:spendora_app/features/auth/domain/repositories/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;

  AuthProvider({required AuthRepository authRepository})
    : _authRepository = authRepository {
    debugPrint('AuthProvider: Initializing with status: $_status');
    _authRepository.authStateChanges.listen(_handleAuthStateChange);
  }

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _setStatus(AuthStatus newStatus) {
    debugPrint('AuthProvider: Status changing from $_status to $newStatus');
    _status = newStatus;
    notifyListeners();
  }

  // Handle auth state changes
  void _handleAuthStateChange(firebase_auth.User? firebaseUser) async {
    debugPrint('AuthProvider: Auth state changed');
    debugPrint('AuthProvider: Firebase User: ${firebaseUser?.email}');
    debugPrint('AuthProvider: Current Status: $_status');

    if (firebaseUser == null) {
      debugPrint(
        'AuthProvider: Firebase user is null, setting unauthenticated',
      );
      _user = null;
      _setStatus(AuthStatus.unauthenticated);
      return;
    }

    try {
      debugPrint('AuthProvider: Loading user data for ${firebaseUser.email}');
      _setStatus(AuthStatus.loading);

      final userData = await _authRepository.getCurrentUserData();
      debugPrint('AuthProvider: Loaded user data: $userData');

      if (userData != null) {
        _user = userData;
        debugPrint('AuthProvider: User data found, setting authenticated');
        _setStatus(AuthStatus.authenticated);
      } else {
        debugPrint('AuthProvider: No user data found, setting unauthenticated');
        _setStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      debugPrint('AuthProvider: Error loading user data - $e');
      _error = e.toString();
      _setStatus(AuthStatus.error);
    }
  }

  // Sign in
  Future<void> signIn(String email, String password) async {
    try {
      debugPrint('AuthProvider: Starting sign in for $email');
      _error = null;
      _setStatus(AuthStatus.loading);

      await _authRepository.signInWithEmailAndPassword(email, password);
      debugPrint('AuthProvider: Sign in successful');
    } catch (e) {
      debugPrint('AuthProvider: Sign in failed - $e');
      _error = e.toString();
      _setStatus(AuthStatus.error);
      rethrow;
    }
  }

  // Register
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint('AuthProvider: Starting registration for $email');
      _error = null;
      _setStatus(AuthStatus.loading);

      await _authRepository.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      debugPrint('AuthProvider: Registration successful');
    } catch (e) {
      debugPrint('AuthProvider: Registration failed - $e');
      _error = e.toString();
      _setStatus(AuthStatus.error);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      debugPrint('AuthProvider: Attempting sign out');
      await _authRepository.signOut();
      debugPrint('AuthProvider: Sign out successful');
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
      debugPrint('AuthProvider: Sign out failed - $e');
      notifyListeners();
      rethrow;
    }
  }

  // Reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('AuthProvider: Attempting password reset for $email');
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      await _authRepository.sendPasswordResetEmail(email);
      debugPrint('AuthProvider: Password reset email sent to $email');

      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
      debugPrint('AuthProvider: Password reset failed - $e');
    } finally {
      notifyListeners();
    }
  }

  // Update profile
  Future<void> updateProfile(String name) async {
    try {
      debugPrint('AuthProvider: Updating profile');
      _error = null;

      await _authRepository.updateProfile(name);
      await refreshUserData();
    } catch (e) {
      debugPrint('AuthProvider: Profile update failed - $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    try {
      debugPrint('AuthProvider: Refreshing user data');
      final userData = await _authRepository.getCurrentUserData();
      if (userData != null) {
        _user = userData;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('AuthProvider: Error refreshing user data - $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      debugPrint('AuthProvider: Deleting account');
      _error = null;
      _setStatus(AuthStatus.loading);

      await _authRepository.deleteAccount();
      debugPrint('AuthProvider: Account deleted successfully');

      _user = null;
      _setStatus(AuthStatus.unauthenticated);
    } catch (e) {
      debugPrint('AuthProvider: Account deletion failed - $e');
      _error = e.toString();
      _setStatus(AuthStatus.error);
      rethrow;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/auth/domain/models/user.dart';
import 'package:spendora_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:spendora_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  final AuthProvider _authProvider;
  bool _isLoading = false;
  String? _error;

  SettingsViewModel({
    required SettingsRepository repository,
    required AuthProvider authProvider,
  }) : _repository = repository,
       _authProvider = authProvider;

  // Getters
  UserPreferences? get preferences => _authProvider.user?.preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get supportedCurrencies => _repository.getSupportedCurrencies();

  Future<void> updateNotifications(bool enabled) async {
    if (preferences == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newPreferences = UserPreferences(
        notifications: enabled,
        language: preferences!.language,
        currency: preferences!.currency,
      );

      await _repository.updateUserPreferences(newPreferences);
      await _refreshUserData();
    } catch (e) {
      _error = e.toString();
      debugPrint('SettingsViewModel: Error updating notifications - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCurrency(String currency) async {
    if (preferences == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newPreferences = UserPreferences(
        notifications: preferences!.notifications,
        language: preferences!.language,
        currency: currency,
      );

      await _repository.updateUserPreferences(newPreferences);
      await _refreshUserData();
    } catch (e) {
      _error = e.toString();
      debugPrint('SettingsViewModel: Error updating currency - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshUserData() async {
    try {
      await _authProvider.refreshUserData();
    } catch (e) {
      debugPrint('SettingsViewModel: Error refreshing user data - $e');
      // Don't throw, as the preference update was successful
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authProvider.deleteAccount();
    } catch (e) {
      _error = e.toString();
      debugPrint('SettingsViewModel: Error deleting account - $e');
      rethrow;
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

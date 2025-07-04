import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/auth/domain/models/user.dart';
import 'package:spendora_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  UserPreferences? _preferences;
  bool _isLoading = false;
  String? _error;

  SettingsViewModel({required SettingsRepository repository})
    : _repository = repository {
    _loadPreferences();
  }

  // Getters
  UserPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get supportedCurrencies => _repository.getSupportedCurrencies();

  Future<void> _loadPreferences() async {
    try {
      _isLoading = true;
      notifyListeners();

      _preferences = await _repository.getUserPreferences();
    } catch (e) {
      _error = e.toString();
      debugPrint('SettingsViewModel: Error loading preferences - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNotifications(bool enabled) async {
    if (_preferences == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newPreferences = UserPreferences(
        notifications: enabled,
        language: _preferences!.language,
        currency: _preferences!.currency,
      );

      await _repository.updateUserPreferences(newPreferences);
      _preferences = newPreferences;
    } catch (e) {
      _error = e.toString();
      debugPrint('SettingsViewModel: Error updating notifications - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCurrency(String currency) async {
    if (_preferences == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newPreferences = UserPreferences(
        notifications: _preferences!.notifications,
        language: _preferences!.language,
        currency: currency,
      );

      await _repository.updateUserPreferences(newPreferences);
      await _repository.updateProfile(currency: currency);
      _preferences = newPreferences;
    } catch (e) {
      _error = e.toString();
      debugPrint('SettingsViewModel: Error updating currency - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateProfile(name: name);
    } catch (e) {
      _error = e.toString();
      debugPrint('SettingsViewModel: Error updating profile - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteAccount();
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

import 'package:spendora_app/features/auth/domain/models/user.dart';

abstract class SettingsRepository {
  /// Get the current user preferences
  Future<UserPreferences> getUserPreferences();

  /// Update user preferences
  Future<void> updateUserPreferences(UserPreferences preferences);

  /// Update user profile
  Future<void> updateProfile({String? name, String? currency});

  /// Get list of supported currencies
  List<String> getSupportedCurrencies();

  /// Delete user account
  Future<void> deleteAccount();
}

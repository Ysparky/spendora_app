import 'package:spendora_app/features/auth/domain/models/user.dart';

abstract class SettingsRepository {
  /// Update user preferences
  Future<void> updateUserPreferences(UserPreferences preferences);

  /// Get list of supported currencies
  List<String> getSupportedCurrencies();
}

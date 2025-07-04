import 'package:spendora_app/features/onboarding/domain/models/onboarding_state.dart';
import 'package:spendora_app/features/transactions/domain/models/category.dart';

abstract class OnboardingRepository {
  /// Get the current onboarding state
  Future<OnboardingState> getOnboardingState();

  /// Update the onboarding state
  Future<void> updateOnboardingState(OnboardingState state);

  /// Load default categories for the user
  Future<void> loadDefaultCategories();

  /// Get list of supported currencies
  List<String> getSupportedCurrencies();

  /// Get default transaction categories
  List<Category> getDefaultCategories();
}

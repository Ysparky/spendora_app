import 'package:flutter/foundation.dart' hide Category;
import 'package:spendora_app/features/onboarding/domain/models/onboarding_state.dart';
import 'package:spendora_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:spendora_app/features/transactions/domain/models/category.dart';

class OnboardingViewModel extends ChangeNotifier {
  final OnboardingRepository _repository;
  OnboardingState _state = OnboardingState.initial();
  bool _isLoading = false;
  String? _error;

  OnboardingViewModel({required OnboardingRepository repository})
    : _repository = repository {
    _loadOnboardingState();
  }

  // Getters
  OnboardingState get state => _state;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get supportedCurrencies => _repository.getSupportedCurrencies();
  List<Category> get defaultCategories => _repository.getDefaultCategories();

  Future<void> _loadOnboardingState() async {
    try {
      _isLoading = true;
      notifyListeners();

      _state = await _repository.getOnboardingState();
    } catch (e) {
      _error = e.toString();
      debugPrint('OnboardingViewModel: Error loading onboarding state - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCurrency(String currency) {
    _state = _state.copyWith(selectedCurrency: currency);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Update onboarding state with selected currency and completion status
      final newState = _state.copyWith(
        hasCompletedOnboarding: true,
        hasLoadedDefaultCategories: true,
      );

      // Load default categories first
      await _repository.loadDefaultCategories();

      // Then update the onboarding state
      await _repository.updateOnboardingState(newState);
      _state = newState;
    } catch (e) {
      _error = e.toString();
      debugPrint('OnboardingViewModel: Error completing onboarding - $e');
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

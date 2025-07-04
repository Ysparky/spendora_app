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
      debugPrint('OnboardingViewModel: Error loading state - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCurrency(String currency) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newState = OnboardingState(
        hasCompletedOnboarding: _state.hasCompletedOnboarding,
        selectedCurrency: currency,
        hasLoadedDefaultCategories: _state.hasLoadedDefaultCategories,
      );

      await _repository.updateOnboardingState(newState);
      _state = newState;
    } catch (e) {
      _error = e.toString();
      debugPrint('OnboardingViewModel: Error updating currency - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDefaultCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.loadDefaultCategories();

      final newState = OnboardingState(
        hasCompletedOnboarding: _state.hasCompletedOnboarding,
        selectedCurrency: _state.selectedCurrency,
        hasLoadedDefaultCategories: true,
      );

      await _repository.updateOnboardingState(newState);
      _state = newState;
    } catch (e) {
      _error = e.toString();
      debugPrint('OnboardingViewModel: Error loading categories - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newState = OnboardingState(
        hasCompletedOnboarding: true,
        selectedCurrency: _state.selectedCurrency,
        hasLoadedDefaultCategories: _state.hasLoadedDefaultCategories,
      );

      await _repository.updateOnboardingState(newState);
      _state = newState;
    } catch (e) {
      _error = e.toString();
      debugPrint('OnboardingViewModel: Error completing onboarding - $e');
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

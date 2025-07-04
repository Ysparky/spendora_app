import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' as foundation;
import 'package:spendora_app/core/services/local_storage_service.dart';
import 'package:spendora_app/features/auth/domain/models/user.dart';
import 'package:spendora_app/features/onboarding/domain/models/onboarding_state.dart';
import 'package:spendora_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:spendora_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:spendora_app/features/transactions/domain/models/category.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;
  final LocalStorageService _localStorage;
  final SettingsRepository _settingsRepository;

  OnboardingRepositoryImpl({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
    required LocalStorageService localStorage,
    required SettingsRepository settingsRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _localStorage = localStorage,
       _settingsRepository = settingsRepository;

  @override
  Future<OnboardingState> getOnboardingState() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception('User data not found');

      final data = doc.data()!;
      final preferences = UserPreferences.fromJson(data['preferences']);
      return OnboardingState(
        hasCompletedOnboarding: _localStorage.hasCompletedOnboarding,
        selectedCurrency: preferences.currency,
        hasLoadedDefaultCategories: false,
      );
    } catch (e) {
      foundation.debugPrint(
        'OnboardingRepository: Error getting onboarding state - $e',
      );
      return OnboardingState.initial();
    }
  }

  @override
  Future<void> updateOnboardingState(OnboardingState state) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Update local storage
      await _localStorage.setHasCompletedOnboarding(
        state.hasCompletedOnboarding,
      );

      // Update Firestore if currency changed
      await _settingsRepository.updateUserPreferences(
        UserPreferences(
          notifications: true,
          language: 'en',
          currency: state.selectedCurrency,
        ),
      );
    } catch (e) {
      foundation.debugPrint(
        'OnboardingRepository: Error updating onboarding state - $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> loadDefaultCategories() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final batch = _firestore.batch();
      final categoriesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories');

      final defaultCategories = getDefaultCategories();
      for (final category in defaultCategories) {
        batch.set(categoriesRef.doc(category.id), {
          ...category.toJson(),
          'userDefined': false,
        });
      }

      await batch.commit();
    } catch (e) {
      foundation.debugPrint(
        'OnboardingRepository: Error loading default categories - $e',
      );
      rethrow;
    }
  }

  @override
  List<String> getSupportedCurrencies() {
    return [
      'USD', // US Dollar
      'EUR', // Euro
      'GBP', // British Pound
      'JPY', // Japanese Yen
      'AUD', // Australian Dollar
      'CAD', // Canadian Dollar
      'CHF', // Swiss Franc
      'CNY', // Chinese Yuan
      'INR', // Indian Rupee
      'NZD', // New Zealand Dollar
      'SGD', // Singapore Dollar
    ];
  }

  @override
  List<Category> getDefaultCategories() {
    return [
      Category(id: 'food', name: 'Food & Dining', icon: '🍔'),
      Category(id: 'transport', name: 'Transportation', icon: '🚗'),
      Category(id: 'housing', name: 'Housing & Rent', icon: '🏠'),
      Category(id: 'utilities', name: 'Utilities', icon: '💡'),
      Category(id: 'entertainment', name: 'Entertainment', icon: '🎮'),
      Category(id: 'shopping', name: 'Shopping', icon: '🛍️'),
      Category(id: 'health', name: 'Healthcare', icon: '🏥'),
      Category(id: 'education', name: 'Education', icon: '📚'),
      Category(id: 'travel', name: 'Travel', icon: '✈️'),
      Category(id: 'savings', name: 'Savings', icon: '💰'),
      Category(id: 'income', name: 'Income', icon: '💵'),
      Category(id: 'other', name: 'Other', icon: '📦'),
    ];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/auth/domain/models/user.dart';
import 'package:spendora_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  SettingsRepositoryImpl({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Future<UserPreferences> getUserPreferences() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // TODO: Load data from getCurrentUserData instead of firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception('User data not found');

      final data = doc.data()!;
      return UserPreferences.fromJson(
        data['preferences'] as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('SettingsRepository: Error getting user preferences - $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      await _firestore.collection('users').doc(user.uid).update({
        'preferences': preferences.toJson(),
      });
    } catch (e) {
      debugPrint('SettingsRepository: Error updating user preferences - $e');
      rethrow;
    }
  }

  @override
  Future<void> updateProfile({String? name, String? currency}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (currency != null) {
        updates['currency'] = currency;
        updates['preferences.currency'] = currency;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
    } catch (e) {
      debugPrint('SettingsRepository: Error updating profile - $e');
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
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Delete Firestore data first
      await _firestore.collection('users').doc(user.uid).delete();

      // Then delete the auth account
      await user.delete();
    } catch (e) {
      debugPrint('SettingsRepository: Error deleting account - $e');
      rethrow;
    }
  }
}

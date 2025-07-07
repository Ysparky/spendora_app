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
  List<String> getSupportedCurrencies() {
    return [
      'PEN', // Peruvian Sol
      'USD', // US Dollar
      'EUR', // Euro
    ];
  }
}

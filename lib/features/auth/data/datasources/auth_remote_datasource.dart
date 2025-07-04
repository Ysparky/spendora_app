import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  AuthRemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _analytics = analytics ?? FirebaseAnalytics.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthRemoteDataSource: Attempting sign in for $email');
      await _analytics.logEvent(
        name: 'login_attempt',
        parameters: {'method': 'email'},
      );

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint(
        'AuthRemoteDataSource: Firebase Auth successful for ${result.user?.email}',
      );

      await _analytics.logEvent(
        name: 'login_success',
        parameters: {'method': 'email'},
      );

      return result;
    } catch (e) {
      debugPrint('AuthRemoteDataSource: Sign in error - $e');
      await _analytics.logEvent(
        name: 'login_error',
        parameters: {'method': 'email', 'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String currency = 'USD',
  }) async {
    try {
      debugPrint('AuthRemoteDataSource: Starting registration for $email');
      await _analytics.logEvent(
        name: 'registration_attempt',
        parameters: {'method': 'email'},
      );

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint(
        'AuthRemoteDataSource: Creating Firestore data for ${result.user?.email}',
      );
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': email,
        'name': name,
        'currency': currency,
        'createdAt': FieldValue.serverTimestamp(),
        'preferences': {
          'notifications': true,
          'language': 'en',
          'currency': currency,
        },
      });

      await _analytics.logEvent(
        name: 'registration_success',
        parameters: {'method': 'email'},
      );

      return result;
    } catch (e) {
      debugPrint('AuthRemoteDataSource: Registration error - $e');
      await _analytics.logEvent(
        name: 'registration_error',
        parameters: {'method': 'email', 'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('AuthRemoteDataSource: Signing out user');
      await _auth.signOut();
      await _analytics.logEvent(name: 'logout_success');
    } catch (e) {
      debugPrint('AuthRemoteDataSource: Sign out error - $e');
      await _analytics.logEvent(
        name: 'logout_error',
        parameters: {'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      debugPrint('AuthRemoteDataSource: Deleting account for ${user.email}');

      // Delete Firestore data first
      await _firestore.collection('users').doc(user.uid).delete();

      // Then delete the auth account
      await user.delete();

      await _analytics.logEvent(name: 'account_deletion_success');
    } catch (e) {
      debugPrint('AuthRemoteDataSource: Account deletion error - $e');
      await _analytics.logEvent(
        name: 'account_deletion_error',
        parameters: {'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<void> updateProfile({String? name, String? currency}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      debugPrint('AuthRemoteDataSource: Updating profile for ${user.email}');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (currency != null) {
        updates['currency'] = currency;
        updates['preferences.currency'] = currency;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
        await _analytics.logEvent(
          name: 'profile_update_success',
          parameters: {'updated_fields': updates.keys.join(', ')},
        );
      }
    } catch (e) {
      debugPrint('AuthRemoteDataSource: Profile update error - $e');
      await _analytics.logEvent(
        name: 'profile_update_error',
        parameters: {'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      debugPrint(
        'AuthRemoteDataSource: Updating email for ${user.email} to $newEmail',
      );

      // Update Firebase Auth email
      await user.verifyBeforeUpdateEmail(newEmail);

      // Update Firestore email
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
      });

      await _analytics.logEvent(name: 'email_update_success');
    } catch (e) {
      debugPrint('AuthRemoteDataSource: Email update error - $e');
      await _analytics.logEvent(
        name: 'email_update_error',
        parameters: {'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      debugPrint('AuthRemoteDataSource: Updating password for ${user.email}');
      await user.updatePassword(newPassword);
      await _analytics.logEvent(name: 'password_update_success');
    } catch (e) {
      debugPrint('AuthRemoteDataSource: Password update error - $e');
      await _analytics.logEvent(
        name: 'password_update_error',
        parameters: {'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint(
        'AuthRemoteDataSource: Sending password reset email to $email',
      );
      await _auth.sendPasswordResetEmail(email: email);
      await _analytics.logEvent(name: 'password_reset_email_sent');
    } catch (e) {
      debugPrint('AuthRemoteDataSource: Password reset email error - $e');
      await _analytics.logEvent(
        name: 'password_reset_email_error',
        parameters: {'error': e.toString()},
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    debugPrint('AuthRemoteDataSource: Fetching user data for $uid');
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      debugPrint('AuthRemoteDataSource: Found user data: ${doc.data()}');
    } else {
      debugPrint('AuthRemoteDataSource: No user data found for $uid');
    }
    return doc.data();
  }
}

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:spendora_app/features/auth/domain/models/user.dart';

abstract class AuthRepository {
  Stream<firebase_auth.User?> get authStateChanges;

  Future<User?> getCurrentUserData();

  Future<void> signInWithEmailAndPassword(String email, String password);

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut();

  Future<void> deleteAccount();

  Future<void> updateProfile(String name);

  Future<void> updateEmail(String newEmail);

  Future<void> updatePassword(String newPassword);

  Future<void> sendPasswordResetEmail(String email);
}

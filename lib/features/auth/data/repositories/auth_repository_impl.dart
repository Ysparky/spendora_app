import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:spendora_app/features/auth/domain/models/user.dart';
import 'package:spendora_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Stream<firebase_auth.User?> get authStateChanges =>
      _dataSource.authStateChanges;

  @override
  Future<User?> getCurrentUserData() async {
    final currentUser = _dataSource.currentUser;
    if (currentUser == null) return null;

    final userData = await _dataSource.getUserData(currentUser.uid);
    if (userData == null) return null;

    // Handle potential null timestamp during document creation
    final createdAt = userData['createdAt'];
    debugPrint('createdAt: $createdAt');
    final createdAtString = createdAt != null
        ? (createdAt as Timestamp).toDate().toIso8601String()
        : DateTime.now().toIso8601String(); // Fallback to current time if null

    return User.fromJson({...userData, 'createdAt': createdAtString});
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    await _dataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await _dataSource.deleteAccount();
  }

  @override
  Future<void> updateProfile(String name) async {
    await _dataSource.updateProfile(name);
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    await _dataSource.updateEmail(newEmail);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _dataSource.updatePassword(newPassword);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _dataSource.sendPasswordResetEmail(email);
  }
}

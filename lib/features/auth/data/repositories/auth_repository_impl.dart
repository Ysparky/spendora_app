import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:spendora_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:spendora_app/features/auth/domain/models/user.dart';
import 'package:spendora_app/features/auth/domain/repositories/auth_repository.dart';

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

    return User.fromJson({
      ...userData,
      'createdAt': userData['createdAt'].toDate().toIso8601String(),
    });
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
    String currency = 'USD',
  }) async {
    await _dataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      currency: currency,
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
  Future<void> updateProfile({String? name, String? currency}) async {
    await _dataSource.updateProfile(name: name, currency: currency);
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

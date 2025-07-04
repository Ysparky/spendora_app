import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.g.dart';
part 'user.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String uid,
    required String email,
    required String name,
    required DateTime createdAt,
    required UserPreferences preferences,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Creates a User from a Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User.fromJson({
      ...data,
      'uid': doc.id,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'preferences': data['preferences'],
    });
  }
}

@freezed
abstract class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool notifications,
    @Default('en') String language,
    @Default('USD') String currency,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

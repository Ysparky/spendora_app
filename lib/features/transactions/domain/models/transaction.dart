import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

/// Type of transaction
enum TransactionType {
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense,
}

/// Recurring transaction frequency
enum RecurringType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
}

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required List<String> tags,
    required DateTime date,
    required String description,
    @Default(false) bool isRecurring,
    RecurringType? recurringType,
    required DateTime createdAt,
    @Default('USD') String currency,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  /// Creates a Transaction from a Firestore document
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction.fromJson({
      ...data,
      'id': doc.id,
      'date': (data['date'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
    });
  }
}

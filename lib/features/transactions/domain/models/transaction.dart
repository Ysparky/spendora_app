import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spendora_app/features/dashboard/presentation/views/dashboard_screen.dart'
    as CurrencyUtils;

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

class DateTimeConverter implements JsonConverter<DateTime, dynamic> {
  const DateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is DateTime) return json;
    throw Exception('Invalid date format');
  }

  @override
  String toJson(DateTime date) => date.toIso8601String();
}

@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required double amount,
    required TransactionType type,
    String? categoryId,
    required List<String> tags,
    @DateTimeConverter() required DateTime date,
    required String description,
    @Default(false) bool isRecurring,
    RecurringType? recurringType,
    @DateTimeConverter() required DateTime createdAt,
    @Default(CurrencyUtils.defaultCurrency) String currency,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  /// Creates a Transaction from a Firestore document
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction.fromJson({
      ...data,
      'id': doc.id,
      'date': (data['date'] as Timestamp).toDate(),
      'createdAt': (data['createdAt'] as Timestamp).toDate(),
    });
  }
}

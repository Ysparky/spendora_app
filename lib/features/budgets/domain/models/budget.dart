import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

/// Type of budget goal
enum BudgetGoalType {
  @JsonValue('savings')
  savings,
  @JsonValue('purchase')
  purchase,
}

@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime startDate,
    required DateTime endDate,
    required String categoryId,
    required BudgetGoalType goalType,
    @Default(false) bool completed,
    @Default('USD') String currency,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

  /// Creates a Budget from a Firestore document
  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget.fromJson({
      ...data,
      'id': doc.id,
      'startDate': (data['startDate'] as Timestamp).toDate().toIso8601String(),
      'endDate': (data['endDate'] as Timestamp).toDate().toIso8601String(),
    });
  }
}

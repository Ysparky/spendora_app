import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary.freezed.dart';
part 'dashboard_summary.g.dart';

@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required double totalBalance,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double monthlySavings,
    required List<CategorySummary> topCategories,
    required List<TransactionSummary> recentTransactions,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryFromJson(json);
}

@freezed
abstract class CategorySummary with _$CategorySummary {
  const factory CategorySummary({
    required String categoryId,
    required String name,
    required String icon,
    required double amount,
    required double percentage,
  }) = _CategorySummary;

  factory CategorySummary.fromJson(Map<String, dynamic> json) =>
      _$CategorySummaryFromJson(json);
}

@freezed
abstract class TransactionSummary with _$TransactionSummary {
  const factory TransactionSummary({
    required String id,
    required String description,
    required double amount,
    required DateTime date,
    required String categoryId,
    required String categoryName,
    required String categoryIcon,
    required String type,
  }) = _TransactionSummary;

  factory TransactionSummary.fromJson(Map<String, dynamic> json) =>
      _$TransactionSummaryFromJson(json);
}

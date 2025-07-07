import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spendora_app/features/transactions/domain/models/category.dart';

part 'dashboard_summary.freezed.dart';
part 'dashboard_summary.g.dart';

@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required Map<String, CurrencyTotal> currencyTotals,
    required List<CategorySummary> topCategories,
    required List<TransactionSummary> recentTransactions,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryFromJson(json);
}

@freezed
abstract class CurrencyTotal with _$CurrencyTotal {
  const factory CurrencyTotal({
    required double totalBalance,
    required double monthlyIncome,
    required double monthlyExpenses,
    required double monthlySavings,
  }) = _CurrencyTotal;

  factory CurrencyTotal.fromJson(Map<String, dynamic> json) =>
      _$CurrencyTotalFromJson(json);
}

@freezed
abstract class CategorySummary with _$CategorySummary, CategoryMixin {
  const CategorySummary._();

  const factory CategorySummary({
    required String categoryId,
    required String name,
    required String icon,
    required double amount,
    required double percentage,
    required String currency,
    @Default({}) Map<String, String> translations,
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
    required String currency,
  }) = _TransactionSummary;

  factory TransactionSummary.fromJson(Map<String, dynamic> json) =>
      _$TransactionSummaryFromJson(json);
}

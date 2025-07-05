import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:spendora_app/core/services/local_storage_service.dart';
import 'package:spendora_app/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:spendora_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart'
    as app;

class DashboardRepositoryImpl implements DashboardRepository {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;
  final LocalStorageService _localStorage;

  DashboardRepositoryImpl({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
    required LocalStorageService localStorage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _localStorage = localStorage;

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Get transactions for the current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      return getDashboardSummaryForPeriod(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
    } catch (e) {
      debugPrint('DashboardRepository: Error getting dashboard summary - $e');
      rethrow;
    }
  }

  @override
  Future<DashboardSummary> getDashboardSummaryForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Get all transactions for the period
      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();

      final transactions = transactionsSnapshot.docs.map((doc) {
        final data = doc.data();
        return app.Transaction.fromJson({
          ...data,
          'id': doc.id,
          'date': (data['date'] as Timestamp).toDate().toIso8601String(),
          'createdAt': (data['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String(),
        });
      }).toList();

      // Group transactions by currency
      final currencyGroups = <String, List<app.Transaction>>{};
      for (final transaction in transactions) {
        final currency = transaction.currency;
        currencyGroups.putIfAbsent(currency, () => []).add(transaction);
      }

      // Calculate totals for each currency
      final currencyTotals = <String, CurrencyTotal>{};
      for (final entry in currencyGroups.entries) {
        final currency = entry.key;
        final currencyTransactions = entry.value;

        double totalIncome = 0;
        double totalExpenses = 0;
        Map<String, double> categoryTotals = {};

        for (final transaction in currencyTransactions) {
          if (transaction.type == app.TransactionType.income) {
            totalIncome += transaction.amount;
          } else {
            totalExpenses += transaction.amount;
            if (transaction.categoryId != null) {
              categoryTotals[transaction.categoryId!] =
                  (categoryTotals[transaction.categoryId!] ?? 0) +
                  transaction.amount;
            }
          }
        }

        currencyTotals[currency] = CurrencyTotal(
          totalBalance: totalIncome - totalExpenses,
          monthlyIncome: totalIncome,
          monthlyExpenses: totalExpenses,
          monthlySavings: totalIncome - totalExpenses,
        );
      }

      // Get category details
      final categoriesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .get();

      final categories = Map.fromEntries(
        categoriesSnapshot.docs.map(
          (doc) => MapEntry(doc.id, {
            'name': doc.data()['name'],
            'icon': doc.data()['icon'],
          }),
        ),
      );

      // Calculate top categories per currency
      final allTopCategories = <CategorySummary>[];
      for (final entry in currencyGroups.entries) {
        final currency = entry.key;
        final currencyTransactions = entry.value;

        // Calculate category totals for this currency
        final categoryTotals = <String, double>{};
        double totalExpenses = 0;

        for (final transaction in currencyTransactions) {
          if (transaction.type == app.TransactionType.expense &&
              transaction.categoryId != null) {
            categoryTotals[transaction.categoryId!] =
                (categoryTotals[transaction.categoryId!] ?? 0) +
                transaction.amount;
            totalExpenses += transaction.amount;
          }
        }

        // Sort and get top categories for this currency
        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        allTopCategories.addAll(
          sortedCategories.take(3).map((entry) {
            final category = categories[entry.key]!;
            return CategorySummary(
              categoryId: entry.key,
              name: category['name'] as String,
              icon: category['icon'] as String,
              amount: entry.value,
              percentage: totalExpenses > 0
                  ? (entry.value / totalExpenses * 100)
                  : 0,
              currency: currency,
            );
          }),
        );
      }

      // Sort all top categories by amount (normalized by currency)
      allTopCategories.sort((a, b) => b.amount.compareTo(a.amount));

      // Get recent transactions
      final recentTransactions = transactions.take(5).map((transaction) {
        final category = categories[transaction.categoryId]!;
        return TransactionSummary(
          id: transaction.id,
          description: transaction.description,
          amount: transaction.amount,
          date: transaction.date,
          categoryId: transaction.categoryId!,
          categoryName: category['name'] as String,
          categoryIcon: category['icon'] as String,
          type: transaction.type.toString(),
          currency: transaction.currency,
        );
      }).toList();

      return DashboardSummary(
        currencyTotals: currencyTotals,
        topCategories: allTopCategories,
        recentTransactions: recentTransactions,
      );
    } catch (e) {
      debugPrint(
        'DashboardRepository: Error getting dashboard summary for period - $e',
      );
      rethrow;
    }
  }
}

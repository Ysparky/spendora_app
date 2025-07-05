import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:spendora_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart'
    as app;

class DashboardRepositoryImpl implements DashboardRepository {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  DashboardRepositoryImpl({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? firebase_auth.FirebaseAuth.instance;

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

      final transactions = transactionsSnapshot.docs
          .map((doc) => app.Transaction.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Calculate summary data
      double totalIncome = 0;
      double totalExpenses = 0;
      Map<String, double> categoryTotals = {};

      for (final transaction in transactions) {
        if (transaction.type == app.TransactionType.income) {
          totalIncome += transaction.amount;
        } else {
          totalExpenses += transaction.amount;
          categoryTotals[transaction.categoryId] =
              (categoryTotals[transaction.categoryId] ?? 0) +
              transaction.amount;
        }
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

      // Calculate top categories
      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topCategories = sortedCategories.take(5).map((entry) {
        final category = categories[entry.key]!;
        return CategorySummary(
          categoryId: entry.key,
          name: category['name'] as String,
          icon: category['icon'] as String,
          amount: entry.value,
          percentage: entry.value / totalExpenses * 100,
        );
      }).toList();

      // Get recent transactions
      final recentTransactions = transactions.take(5).map((transaction) {
        final category = categories[transaction.categoryId]!;
        return TransactionSummary(
          id: transaction.id,
          description: transaction.description,
          amount: transaction.amount,
          date: transaction.date,
          categoryId: transaction.categoryId,
          categoryName: category['name'] as String,
          categoryIcon: category['icon'] as String,
          type: transaction.type.toString(),
        );
      }).toList();

      return DashboardSummary(
        totalBalance: totalIncome - totalExpenses,
        monthlyIncome: totalIncome,
        monthlyExpenses: totalExpenses,
        monthlySavings: totalIncome - totalExpenses,
        topCategories: topCategories,
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

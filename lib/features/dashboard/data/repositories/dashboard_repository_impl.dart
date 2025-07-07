import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:spendora_app/core/utils/currency_utils.dart';
import 'package:spendora_app/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:spendora_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';

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

      // Get all transactions for total balance
      final allTransactionsQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions');

      final allTransactionsSnapshot = await allTransactionsQuery.get();

      // Calculate total balance from all transactions
      final allTransactions = allTransactionsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Transaction.fromJson({
          ...data,
          'id': doc.id,
          'date': (data['date'] as Timestamp).toDate().toIso8601String(),
          'createdAt': (data['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String(),
        });
      }).toList();

      // Group all transactions by currency
      final currencyGroups = <String, List<Transaction>>{};
      for (final transaction in allTransactions) {
        currencyGroups.putIfAbsent(transaction.currency, () => []);
        currencyGroups[transaction.currency]!.add(transaction);
      }

      // Calculate total balance for each currency
      final currencyTotals = <String, CurrencyTotal>{};
      final now = DateTime.now();
      for (final entry in currencyGroups.entries) {
        final currency = entry.key;
        final currencyTransactions = entry.value;

        double totalBalance = 0;
        for (final transaction in currencyTransactions) {
          if (transaction.type == TransactionType.income) {
            totalBalance += transaction.amount;
          } else {
            totalBalance -= transaction.amount;
          }
        }

        // Get monthly transactions for this currency
        final startOfMonth = DateTime(now.year, now.month, 1, 0, 0, 0);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

        final monthlyTransactions = currencyTransactions.where((t) {
          return !t.date.isBefore(startOfMonth) && !t.date.isAfter(endOfMonth);
        }).toList();

        double monthlyIncome = 0;
        double monthlyExpenses = 0;
        for (final transaction in monthlyTransactions) {
          if (transaction.type == TransactionType.income) {
            monthlyIncome += transaction.amount;
          } else {
            monthlyExpenses += transaction.amount;
          }
        }

        currencyTotals[currency] = CurrencyTotal(
          totalBalance: totalBalance,
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
          monthlySavings: monthlyIncome - monthlyExpenses,
        );
      }

      // If there are no transactions, return default values with user's preferred currency
      if (currencyTotals.isEmpty) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        final userCurrency =
            userDoc.data()?['preferences']?['currency'] ??
            CurrencyUtils.defaultCurrency;

        return DashboardSummary(
          currencyTotals: {
            userCurrency: const CurrencyTotal(
              totalBalance: 0,
              monthlyIncome: 0,
              monthlyExpenses: 0,
              monthlySavings: 0,
            ),
          },
          topCategories: [],
          recentTransactions: [],
        );
      }

      // Get monthly transactions for categories and recent transactions
      final monthlyDashboard = await getDashboardSummaryForPeriod(
        startDate: DateTime(now.year, now.month, 1, 0, 0, 0),
        endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      );

      return DashboardSummary(
        currencyTotals: currencyTotals,
        topCategories: monthlyDashboard.topCategories,
        recentTransactions: monthlyDashboard.recentTransactions,
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

      // Get transactions
      final transactionsQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions');

      Query<Map<String, dynamic>> query = transactionsQuery;
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );

      final transactionsSnapshot = await query.get();

      // If there are no transactions, return default values with user's preferred currency
      if (transactionsSnapshot.docs.isEmpty) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        final userCurrency =
            userDoc.data()?['preferences']?['currency'] ??
            CurrencyUtils.defaultCurrency;

        return DashboardSummary(
          currencyTotals: {
            userCurrency: const CurrencyTotal(
              totalBalance: 0,
              monthlyIncome: 0,
              monthlyExpenses: 0,
              monthlySavings: 0,
            ),
          },
          topCategories: [],
          recentTransactions: [],
        );
      }

      final transactions = transactionsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Transaction.fromJson({
          ...data,
          'id': doc.id,
          'date': (data['date'] as Timestamp).toDate().toIso8601String(),
          'createdAt': (data['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String(),
        });
      }).toList();

      // Group transactions by currency
      final currencyGroups = <String, List<Transaction>>{};
      for (final transaction in transactions) {
        currencyGroups.putIfAbsent(transaction.currency, () => []);
        currencyGroups[transaction.currency]!.add(transaction);
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
          if (transaction.type == TransactionType.income) {
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

      // Get category details from global categories
      final categoriesSnapshot = await _firestore
          .collection('categories')
          .get();

      final categories = Map.fromEntries(
        categoriesSnapshot.docs.map((doc) {
          final data = doc.data();
          final translations = data['translations'];
          return MapEntry(doc.id, {
            'name': data['name'],
            'icon': data['icon'],
            'translations': translations is Map
                ? Map<String, String>.from(translations)
                : <String, String>{},
          });
        }),
      );

      // Calculate top categories per currency
      final allTopCategories = <CategorySummary>[];
      for (final entry in currencyGroups.entries) {
        final currency = entry.key;
        final currencyTransactions = entry.value;

        // Group transactions by category
        final categoryTotals = <String, double>{};
        double totalExpenses = 0;
        for (final transaction in currencyTransactions) {
          if (transaction.type == TransactionType.expense &&
              transaction.categoryId != null) {
            categoryTotals[transaction.categoryId!] =
                (categoryTotals[transaction.categoryId!] ?? 0) +
                transaction.amount;
            totalExpenses += transaction.amount;
          }
        }

        // Sort categories by total amount
        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Take top 5 categories
        for (final entry in sortedCategories.take(5)) {
          final categoryId = entry.key;
          final categoryData = categories[categoryId];
          if (categoryData != null) {
            allTopCategories.add(
              CategorySummary(
                categoryId: categoryId,
                name: categoryData['name'] as String,
                icon: categoryData['icon'] as String,
                amount: entry.value,
                percentage: totalExpenses > 0
                    ? (entry.value / totalExpenses * 100)
                    : 0,
                currency: currency,
                translations:
                    (categoryData['translations'] as Map<String, String>?) ??
                    {},
              ),
            );
          }
        }
      }

      // Get recent transactions
      final recentTransactions = transactions.take(5).map((transaction) {
        final categoryData = transaction.categoryId != null
            ? categories[transaction.categoryId]
            : null;
        return TransactionSummary(
          id: transaction.id,
          description: transaction.description,
          amount: transaction.amount,
          date: transaction.date,
          categoryId: transaction.categoryId ?? 'other',
          categoryName: categoryData?['name'] as String? ?? 'Other',
          categoryIcon: categoryData?['icon'] as String? ?? '📦',
          type: transaction.type.toString().split('.').last,
          currency: transaction.currency,
        );
      }).toList();

      return DashboardSummary(
        currencyTotals: currencyTotals,
        topCategories: allTopCategories,
        recentTransactions: recentTransactions,
      );
    } catch (e) {
      debugPrint('DashboardRepository: Error getting summary - $e');
      rethrow;
    }
  }
}

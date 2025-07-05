import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' hide Category;
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
import 'package:spendora_app/features/transactions/domain/models/category.dart';
import 'package:spendora_app/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  TransactionRepositoryImpl({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getTransactionsCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  Query<Map<String, dynamic>> _applyDateFilter(
    Query<Map<String, dynamic>> query,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }
    return query.orderBy('date', descending: true);
  }

  @override
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      Query<Map<String, dynamic>> query = _getTransactionsCollection();
      query = _applyDateFilter(query, startDate, endDate);
      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
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
    } catch (e) {
      debugPrint('TransactionRepository: Error getting transactions - $e');
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return getTransactions(startDate: startDate, endDate: endDate);
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final doc = await _getTransactionsCollection().add({
        'amount': transaction.amount,
        'type': transaction.type.toString().split('.').last,
        'categoryId': transaction.categoryId,
        'tags': transaction.tags,
        'date': Timestamp.fromDate(transaction.date),
        'description': transaction.description,
        'isRecurring': transaction.isRecurring,
        'recurringType': transaction.recurringType?.toString().split('.').last,
        'createdAt': Timestamp.fromDate(transaction.createdAt),
        'currency': transaction.currency,
      });

      final snapshot = await doc.get();
      final data = snapshot.data()!;
      return Transaction.fromJson({
        ...data,
        'id': snapshot.id,
        'date': (data['date'] as Timestamp).toDate().toIso8601String(),
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });
    } catch (e) {
      debugPrint('TransactionRepository: Error creating transaction - $e');
      rethrow;
    }
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      await _getTransactionsCollection().doc(transaction.id).update({
        'amount': transaction.amount,
        'type': transaction.type.toString().split('.').last,
        'categoryId': transaction.categoryId,
        'tags': transaction.tags,
        'date': Timestamp.fromDate(transaction.date),
        'description': transaction.description,
        'isRecurring': transaction.isRecurring,
        'recurringType': transaction.recurringType?.toString().split('.').last,
        'currency': transaction.currency,
      });

      final doc = await _getTransactionsCollection().doc(transaction.id).get();
      final data = doc.data()!;
      return Transaction.fromJson({
        ...data,
        'id': doc.id,
        'date': (data['date'] as Timestamp).toDate().toIso8601String(),
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });
    } catch (e) {
      debugPrint('TransactionRepository: Error updating transaction - $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _getTransactionsCollection().doc(id).delete();
    } catch (e) {
      debugPrint('TransactionRepository: Error deleting transaction - $e');
      rethrow;
    }
  }

  @override
  Future<Transaction> getTransactionById(String id) async {
    try {
      final doc = await _getTransactionsCollection().doc(id).get();
      if (!doc.exists) {
        throw Exception('Transaction not found');
      }

      final data = doc.data()!;
      return Transaction.fromJson({
        ...data,
        'id': doc.id,
        'date': (data['date'] as Timestamp).toDate().toIso8601String(),
        'createdAt': (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String(),
      });
    } catch (e) {
      debugPrint('TransactionRepository: Error getting transaction by ID - $e');
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(
    String categoryId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _getTransactionsCollection().where(
        'categoryId',
        isEqualTo: categoryId,
      );
      query = _applyDateFilter(query, startDate, endDate);
      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
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
    } catch (e) {
      debugPrint(
        'TransactionRepository: Error getting transactions by category - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByTag(
    String tag, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _getTransactionsCollection().where(
        'tags',
        arrayContains: tag,
      );
      query = _applyDateFilter(query, startDate, endDate);
      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
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
    } catch (e) {
      debugPrint(
        'TransactionRepository: Error getting transactions by tag - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getRecurringTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _getTransactionsCollection().where(
        'isRecurring',
        isEqualTo: true,
      );
      query = _applyDateFilter(query, startDate, endDate);
      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
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
    } catch (e) {
      debugPrint(
        'TransactionRepository: Error getting recurring transactions - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .get();

      return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('TransactionRepository: Error getting categories - $e');
      rethrow;
    }
  }
}

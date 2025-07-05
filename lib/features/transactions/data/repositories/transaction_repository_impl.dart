import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
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

  @override
  Future<List<Transaction>> getTransactions() async {
    try {
      final querySnapshot = await _getTransactionsCollection()
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc))
          .toList();
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
    try {
      final querySnapshot = await _getTransactionsCollection()
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint(
        'TransactionRepository: Error getting transactions for period - $e',
      );
      rethrow;
    }
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final docRef = await _getTransactionsCollection().add({
        'amount': transaction.amount,
        'type': transaction.type.toString().split('.').last,
        'categoryId': transaction.categoryId,
        'tags': transaction.tags,
        'date': transaction.date,
        'description': transaction.description,
        'isRecurring': transaction.isRecurring,
        'recurringType': transaction.recurringType?.toString().split('.').last,
        'createdAt': DateTime.now(),
        'currency': transaction.currency,
      });

      final doc = await docRef.get();
      return Transaction.fromFirestore(doc);
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
        'date': transaction.date,
        'description': transaction.description,
        'isRecurring': transaction.isRecurring,
        'recurringType': transaction.recurringType?.toString().split('.').last,
        'currency': transaction.currency,
      });

      final doc = await _getTransactionsCollection().doc(transaction.id).get();
      return Transaction.fromFirestore(doc);
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
      return Transaction.fromFirestore(doc);
    } catch (e) {
      debugPrint('TransactionRepository: Error getting transaction by ID - $e');
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    try {
      final querySnapshot = await _getTransactionsCollection()
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint(
        'TransactionRepository: Error getting transactions by category - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByTag(String tag) async {
    try {
      final querySnapshot = await _getTransactionsCollection()
          .where('tags', arrayContains: tag)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint(
        'TransactionRepository: Error getting transactions by tag - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> getRecurringTransactions() async {
    try {
      final querySnapshot = await _getTransactionsCollection()
          .where('isRecurring', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint(
        'TransactionRepository: Error getting recurring transactions - $e',
      );
      rethrow;
    }
  }
}

import 'package:spendora_app/features/transactions/domain/models/transaction.dart';

abstract class TransactionRepository {
  /// Fetches all transactions for the current user
  Future<List<Transaction>> getTransactions();

  /// Fetches transactions for a specific time period
  Future<List<Transaction>> getTransactionsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Creates a new transaction
  Future<Transaction> createTransaction(Transaction transaction);

  /// Updates an existing transaction
  Future<Transaction> updateTransaction(Transaction transaction);

  /// Deletes a transaction
  Future<void> deleteTransaction(String id);

  /// Fetches a single transaction by ID
  Future<Transaction> getTransactionById(String id);

  /// Fetches transactions by category
  Future<List<Transaction>> getTransactionsByCategory(String categoryId);

  /// Fetches transactions by tag
  Future<List<Transaction>> getTransactionsByTag(String tag);

  /// Fetches recurring transactions
  Future<List<Transaction>> getRecurringTransactions();
}

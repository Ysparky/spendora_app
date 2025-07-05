import 'package:flutter/foundation.dart' hide Category;
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
import 'package:spendora_app/features/transactions/domain/models/category.dart';
import 'package:spendora_app/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;
  bool _isLoading = false;
  bool _isCategoriesLoading = false;
  String? _error;
  List<Category> _categories = [];
  List<Transaction>? _transactions;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  bool get isLoading => _isLoading;
  bool get isCategoriesLoading => _isCategoriesLoading;
  String? get error => _error;
  List<Category> get categories => _categories;
  List<Transaction>? get transactions => _transactions;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  TransactionViewModel({required TransactionRepository repository})
    : _repository = repository {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      _isCategoriesLoading = true;
      notifyListeners();

      _categories = await _repository.getCategories();
      _error = null;
    } catch (e) {
      _error = 'Failed to load categories: $e';
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();
      _transactions = await _repository.getTransactions();
    } catch (e) {
      _error = 'Failed to load transactions';
      debugPrint('TransactionViewModel: Error loading transactions - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDateRange(DateTime start, DateTime end) async {
    _startDate = start;
    _endDate = end;
    await loadTransactions();
  }

  Future<void> createTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.createTransaction(transaction);
      await loadTransactions(); // Refresh the list after creating
      _error = null;
    } catch (e) {
      _error = 'Failed to create transaction: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      _error = 'Failed to update transaction';
      debugPrint('TransactionViewModel: Error updating transaction - $e');
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      _error = 'Failed to delete transaction';
      debugPrint('TransactionViewModel: Error deleting transaction - $e');
      notifyListeners();
    }
  }

  Future<Transaction?> getTransactionById(String id) async {
    try {
      return await _repository.getTransactionById(id);
    } catch (e) {
      _error = 'Failed to load transaction';
      debugPrint('TransactionViewModel: Error loading transaction - $e');
      notifyListeners();
      return null;
    }
  }

  Future<void> filterByCategory(String categoryId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transactions = await _repository.getTransactionsByCategory(categoryId);
    } catch (e) {
      _error = 'Failed to filter transactions';
      debugPrint('TransactionViewModel: Error filtering by category - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByTag(String tag) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transactions = await _repository.getTransactionsByTag(tag);
    } catch (e) {
      _error = 'Failed to filter transactions';
      debugPrint('TransactionViewModel: Error filtering by tag - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecurringTransactions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transactions = await _repository.getRecurringTransactions();
    } catch (e) {
      _error = 'Failed to load recurring transactions';
      debugPrint(
        'TransactionViewModel: Error loading recurring transactions - $e',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

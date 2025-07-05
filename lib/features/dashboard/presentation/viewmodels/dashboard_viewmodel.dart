import 'package:flutter/foundation.dart';
import 'package:spendora_app/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:spendora_app/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardViewModel({required DashboardRepository repository})
    : _repository = repository;

  DashboardSummary? _summary;
  bool _isLoading = false;
  String? _error;

  DashboardSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardSummary() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _summary = await _repository.getDashboardSummary();
    } catch (e) {
      _error = 'Failed to load dashboard summary';
      debugPrint('DashboardViewModel: Error loading summary - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardSummaryForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _summary = await _repository.getDashboardSummaryForPeriod(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = 'Failed to load dashboard summary for period';
      debugPrint('DashboardViewModel: Error loading summary for period - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

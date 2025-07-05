import 'package:spendora_app/features/dashboard/domain/models/dashboard_summary.dart';

abstract class DashboardRepository {
  /// Fetches the dashboard summary data for the current user
  Future<DashboardSummary> getDashboardSummary();

  /// Fetches the dashboard summary data for a specific time period
  Future<DashboardSummary> getDashboardSummaryForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  });
}

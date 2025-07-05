import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/core/theme/app_theme.dart';
import 'package:spendora_app/features/dashboard/domain/models/dashboard_summary.dart';
import 'package:spendora_app/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardSummary();
    });
  }

  Future<void> _addTransaction(BuildContext context) async {
    final result = await context.push('/transactions/add');
    // Refresh dashboard if transaction was added
    if (result == true && mounted) {
      context.read<DashboardViewModel>().loadDashboardSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadDashboardSummary,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final summary = viewModel.summary;
          if (summary == null) {
            return const Center(child: Text('No data available'));
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadDashboardSummary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BalanceCard(summary: summary),
                const SizedBox(height: 16),
                _MonthlyOverviewCard(summary: summary),
                const SizedBox(height: 16),
                _TopCategoriesCard(categories: summary.topCategories),
                const SizedBox(height: 16),
                _RecentTransactionsCard(
                  transactions: summary.recentTransactions,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final DashboardSummary summary;

  const _BalanceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Balance', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(summary.totalBalance),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: summary.totalBalance >= 0
                    ? AppTheme.light(context).colorScheme.primary
                    : AppTheme.light(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyOverviewCard extends StatelessWidget {
  final DashboardSummary summary;

  const _MonthlyOverviewCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Overview', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _OverviewItem(
              icon: Icons.arrow_upward,
              label: 'Income',
              amount: summary.monthlyIncome,
              color: AppTheme.light(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _OverviewItem(
              icon: Icons.arrow_downward,
              label: 'Expenses',
              amount: summary.monthlyExpenses,
              color: AppTheme.light(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            _OverviewItem(
              icon: Icons.savings,
              label: 'Savings',
              amount: summary.monthlySavings,
              color: AppTheme.light(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _OverviewItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Text(
          currencyFormat.format(amount),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TopCategoriesCard extends StatelessWidget {
  final List<CategorySummary> categories;

  const _TopCategoriesCard({required this.categories});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Top Categories', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.push('/categories'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...categories.map(
              (category) => InkWell(
                onTap: () => context.push(
                  '/transactions',
                  extra: {'categoryId': category.categoryId},
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: category.percentage / 100,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        currencyFormat.format(category.amount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  final List<TransactionSummary> transactions;

  const _RecentTransactionsCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Transactions', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () => context.push('/transactions'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...transactions.map(
              (transaction) => ListTile(
                leading: Text(transaction.categoryIcon),
                title: Text(transaction.description),
                subtitle: Text(dateFormat.format(transaction.date)),
                trailing: Text(
                  currencyFormat.format(transaction.amount),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: transaction.type == TransactionType.income.toString()
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () =>
                    context.push('/transactions/details/${transaction.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

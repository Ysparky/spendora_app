import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/core/theme/app_theme.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
import 'package:spendora_app/features/transactions/presentation/viewmodels/transaction_viewmodel.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadTransactions();
    });
  }

  Future<void> _showDateRangePicker(
    BuildContext context,
    TransactionViewModel viewModel,
  ) async {
    final initialDateRange = DateTimeRange(
      start: viewModel.startDate,
      end: viewModel.endDate,
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
    );

    if (pickedDateRange != null) {
      await viewModel.setDateRange(pickedDateRange.start, pickedDateRange.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDateRangePicker(
              context,
              context.read<TransactionViewModel>(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<TransactionViewModel>(
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
                    onPressed: viewModel.loadTransactions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final transactions = viewModel.transactions;
          if (transactions == null || transactions.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadTransactions,
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _TransactionListItem(
                  transaction: transaction,
                  onTap: () =>
                      context.push('/transactions/details/${transaction.id}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    final viewModel = context.read<TransactionViewModel>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Transactions'),
              onTap: () {
                viewModel.loadTransactions();
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Recurring Transactions'),
              onTap: () {
                viewModel.loadRecurringTransactions();
                context.pop();
              },
            ),
            // Add more filter options here (e.g., by category, by tag)
          ],
        ),
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionListItem({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM d, y');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.type == TransactionType.income
            ? AppTheme.light(context).colorScheme.primary
            : AppTheme.light(context).colorScheme.error,
        child: Icon(
          transaction.type == TransactionType.income
              ? Icons.arrow_upward
              : Icons.arrow_downward,
          color: Colors.white,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(dateFormat.format(transaction.date)),
      trailing: Text(
        currencyFormat.format(transaction.amount),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: transaction.type == TransactionType.income
              ? AppTheme.light(context).colorScheme.primary
              : AppTheme.light(context).colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}

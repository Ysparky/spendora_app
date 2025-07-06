import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
import 'package:spendora_app/features/transactions/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spendora_app/l10n/app_localizations.dart';

class TransactionListScreen extends StatefulWidget {
  final String? categoryId;

  const TransactionListScreen({super.key, this.categoryId});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  Future<void> _refreshTransactions() async {
    final viewModel = context.read<TransactionViewModel>();
    if (widget.categoryId != null) {
      await viewModel.loadTransactionsByCategory(widget.categoryId!);
    } else {
      await viewModel.loadTransactions();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshTransactions();
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
      // Set end date to end of day (23:59:59)
      final endOfDay = DateTime(
        pickedDateRange.end.year,
        pickedDateRange.end.month,
        pickedDateRange.end.day,
        23,
        59,
        59,
      );
      await viewModel.setDateRange(pickedDateRange.start, endOfDay);
      if (mounted) {
        await _refreshTransactions();
      }
    }
  }

  void _resetDateRange(TransactionViewModel viewModel) {
    final now = DateTime.now();
    final defaultStartDate = now.subtract(const Duration(days: 30));
    viewModel
        .setDateRange(
          defaultStartDate,
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        )
        .then((_) {
          if (mounted) {
            _refreshTransactions();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryId != null
              ? l10n.categoryTransactions
              : l10n.transactions,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDateRangePicker(
              context,
              context.read<TransactionViewModel>(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.resetToLast30Days,
            onPressed: () =>
                _resetDateRange(context.read<TransactionViewModel>()),
          ),
          if (widget.categoryId == null)
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
                    onPressed: _refreshTransactions,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final transactions = viewModel.transactions;
          if (transactions == null || transactions.isEmpty) {
            return Center(child: Text(l10n.noTransactionsFound));
          }

          return RefreshIndicator(
            onRefresh: _refreshTransactions,
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
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.read<TransactionViewModel>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.filterTransactions),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(l10n.allTransactions),
              onTap: () {
                viewModel.loadTransactions();
                context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: Text(l10n.recurringTransactions),
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
    final currencyFormat = NumberFormat.currency(symbol: transaction.currency);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.type == TransactionType.income
            ? theme.colorScheme.primary
            : theme.colorScheme.error,
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
              ? theme.colorScheme.primary
              : theme.colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}

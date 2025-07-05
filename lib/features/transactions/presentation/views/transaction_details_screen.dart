import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/features/transactions/domain/models/category.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
import 'package:spendora_app/features/transactions/presentation/viewmodels/transaction_viewmodel.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailsScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  Transaction? _transaction;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final transaction = await context
          .read<TransactionViewModel>()
          .getTransactionById(widget.transactionId);

      if (mounted) {
        setState(() {
          _transaction = transaction;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load transaction details';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<TransactionViewModel>().deleteTransaction(
          widget.transactionId,
        );
        if (mounted) {
          context.pop(true); // Pop with refresh flag
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete transaction')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      symbol: _transaction?.currency ?? 'USD',
    );
    final dateFormat = DateFormat('MMM d, y');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          if (_transaction != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final refreshNeeded = await context.push<bool>(
                  '/transactions/edit/${widget.transactionId}',
                );
                if (refreshNeeded == true && mounted) {
                  _loadTransaction();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTransaction,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _transaction == null
          ? const Center(child: Text('Transaction not found'))
          : Consumer<TransactionViewModel>(
              builder: (context, viewModel, child) {
                final category = viewModel.categories.firstWhere(
                  (c) => c.id == _transaction!.categoryId,
                  orElse: () => const Category(
                    id: 'unknown',
                    name: 'Unknown Category',
                    icon: '❓',
                  ),
                );

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      _transaction!.type ==
                                          TransactionType.income
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.error,
                                  child: Icon(
                                    _transaction!.type == TransactionType.income
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _transaction!.description,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      Text(
                                        dateFormat.format(_transaction!.date),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(_transaction!.amount),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color:
                                        _transaction!.type ==
                                            TransactionType.income
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            _DetailItem(
                              label: 'Category',
                              child: Row(
                                children: [
                                  Text(category.icon),
                                  const SizedBox(width: 8),
                                  Text(category.name),
                                ],
                              ),
                            ),
                            if (_transaction!.tags.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _DetailItem(
                                label: 'Tags',
                                child: Wrap(
                                  spacing: 8,
                                  children: _transaction!.tags
                                      .map((tag) => Chip(label: Text(tag)))
                                      .toList(),
                                ),
                              ),
                            ],
                            if (_transaction!.isRecurring &&
                                _transaction!.recurringType != null) ...[
                              const SizedBox(height: 16),
                              _DetailItem(
                                label: 'Recurring',
                                child: Text(
                                  _transaction!.recurringType
                                      .toString()
                                      .split('.')
                                      .last
                                      .toUpperCase(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _DetailItem(
                              label: 'Currency',
                              child: Text(_transaction!.currency),
                            ),
                            const SizedBox(height: 16),
                            _DetailItem(
                              label: 'Created',
                              child: Text(
                                dateFormat.format(_transaction!.createdAt),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final Widget child;

  const _DetailItem({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        DefaultTextStyle(
          style: theme.textTheme.bodyLarge ?? const TextStyle(),
          child: child,
        ),
      ],
    );
  }
}

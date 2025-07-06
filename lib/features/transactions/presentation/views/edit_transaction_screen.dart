import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:spendora_app/features/transactions/domain/models/category.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
import 'package:spendora_app/features/transactions/presentation/viewmodels/transaction_viewmodel.dart';
import 'package:spendora_app/l10n/app_localizations.dart';

class EditTransactionScreen extends StatefulWidget {
  final String transactionId;

  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  RecurringType? _recurringType;
  bool _isLoading = true;
  String? _error;
  Transaction? _transaction;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = 'USD'; // Will be updated when transaction is loaded
    _loadTransaction();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _tagController.dispose();
    super.dispose();
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
          if (transaction != null) {
            _descriptionController.text = transaction.description;
            _amountController.text = transaction.amount.toString();
            _type = transaction.type;
            _selectedCategoryId = transaction.categoryId;
            _tags.addAll(transaction.tags);
            _selectedDate = transaction.date;
            _isRecurring = transaction.isRecurring;
            _recurringType = transaction.recurringType;
            _selectedCurrency = transaction.currency;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)!.errorLoadingTransaction;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final l10n = AppLocalizations.of(context)!;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectCategory)));
      return;
    }

    if (_transaction == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.transactionNotFound)));
      return;
    }

    final updatedTransaction = Transaction(
      id: _transaction!.id,
      amount: amount,
      type: _type,
      categoryId: _selectedCategoryId!,
      tags: _tags,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
      isRecurring: _isRecurring,
      recurringType: _isRecurring ? _recurringType : null,
      createdAt: _transaction!.createdAt,
      currency: _selectedCurrency,
    );

    try {
      await context.read<TransactionViewModel>().updateTransaction(
        updatedTransaction,
      );
      if (mounted) {
        context.pop(true); // Pop with refresh flag
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorUpdatingTransaction)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    );
    final currencyFormat = NumberFormat.currency(symbol: _selectedCurrency);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editTransaction)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editTransaction)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTransaction,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_transaction == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editTransaction)),
        body: Center(child: Text(l10n.transactionNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editTransaction)),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Transaction Type
                    SegmentedButton<TransactionType>(
                      segments: [
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text(l10n.expense),
                          icon: const Icon(Icons.arrow_downward),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text(l10n.income),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (Set<TransactionType> selected) {
                        setState(() {
                          _type = selected.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount and Currency
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              labelText: l10n.amount,
                              prefixText: NumberFormat.currency(
                                symbol: _selectedCurrency,
                                decimalDigits: 0,
                              ).currencySymbol,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.required;
                              }
                              if (double.tryParse(value) == null) {
                                return l10n.invalidAmount;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Consumer<SettingsViewModel>(
                            builder: (context, settingsViewModel, _) {
                              return DropdownButtonFormField<String>(
                                value: _selectedCurrency,
                                decoration: InputDecoration(
                                  labelText: l10n.currency,
                                ),
                                items: settingsViewModel.supportedCurrencies
                                    .map(
                                      (currency) => DropdownMenuItem(
                                        value: currency,
                                        child: Text(currency),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCurrency = value;
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: l10n.description),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category
                    if (_type == TransactionType.expense)
                      if (viewModel.isCategoriesLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (viewModel.error != null)
                        Text(
                          l10n.errorLoadingCategories(viewModel.error!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(labelText: l10n.category),
                          items: viewModel.categories
                              ?.map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Row(
                                    children: [
                                      Text(category.icon),
                                      const SizedBox(width: 8),
                                      Text(category.name),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        ),
                    const SizedBox(height: 16),

                    // Date
                    ListTile(
                      title: const Text('Date'),
                      subtitle: Text(dateFormat.format(_selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),

                    // Tags
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              labelText: 'Add Tag',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                onDeleted: () => _removeTag(tag),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Recurring Transaction
                    SwitchListTile(
                      title: const Text('Recurring Transaction'),
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() {
                          _isRecurring = value;
                          if (!value) {
                            _recurringType = null;
                          }
                        });
                      },
                    ),
                    if (_isRecurring) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<RecurringType>(
                        value: _recurringType,
                        decoration: const InputDecoration(
                          labelText: 'Recurring Type',
                        ),
                        items: RecurringType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.toString().split('.').last.toUpperCase(),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _recurringType = value;
                          });
                        },
                        validator: (value) {
                          if (_isRecurring && value == null) {
                            return 'Please select a recurring type';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showDeleteConfirmation(context),
                            child: Text(l10n.delete),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Text(l10n.save),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
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
            SnackBar(content: Text(l10n.errorDeletingTransaction)),
          );
        }
      }
    }
  }
}

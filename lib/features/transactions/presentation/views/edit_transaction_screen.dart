import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendora_app/features/transactions/domain/models/transaction.dart';
import 'package:spendora_app/features/transactions/presentation/viewmodels/transaction_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
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
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load transaction';
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

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    if (_transaction == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction not found')));
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
      currency: _transaction!.currency,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update transaction')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Transaction')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Transaction')),
        body: Center(
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
        ),
      );
    }

    if (_transaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Transaction')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Transaction')),
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
                      segments: const [
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text('Expense'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text('Income'),
                          icon: Icon(Icons.arrow_upward),
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

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category
                    if (viewModel.isCategoriesLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (viewModel.error != null)
                      Text(
                        'Error loading categories: ${viewModel.error}',
                        style: TextStyle(color: theme.colorScheme.error),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: viewModel.categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Row(
                              children: [
                                Text(category.icon),
                                const SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
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
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _submit,
            child: const Text('Update Transaction'),
          ),
        ),
      ),
    );
  }
}

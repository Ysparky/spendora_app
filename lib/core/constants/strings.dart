/// App-wide string constants
class Strings {
  const Strings._();

  // App
  static const String appName = 'Spendora';

  // Navigation
  static const String home = 'Home';
  static const String transactions = 'Transactions';
  static const String budgets = 'Budgets';
  static const String reports = 'Reports';
  static const String settings = 'Settings';

  // Actions
  static const String add = 'Add';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String confirm = 'Confirm';

  // Transaction Types
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const String transfer = 'Transfer';

  // Categories
  static const String category = 'Category';
  static const String categories = 'Categories';
  static const String addCategory = 'Add Category';

  // Budgets
  static const String budget = 'Budget';
  static const String remaining = 'Remaining';
  static const String spent = 'Spent';
  static const String setBudget = 'Set Budget';

  // Error Messages
  static const String errorGeneric = 'Something went wrong';
  static const String errorNoInternet = 'No internet connection';
  static const String errorInvalidAmount = 'Please enter a valid amount';
  static const String errorInvalidDate = 'Please enter a valid date';
  static const String errorRequiredField = 'This field is required';

  // Empty States
  static const String emptyTransactions = 'No transactions yet';
  static const String emptyBudgets = 'No budgets set';
  static const String emptyCategories = 'No categories found';

  // Success Messages
  static const String successTransaction = 'Transaction added successfully';
  static const String successBudget = 'Budget set successfully';
  static const String successCategory = 'Category added successfully';
}

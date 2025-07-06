// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Spendora';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginButton => 'Login';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerButton => 'Create Account';

  @override
  String get fullNameHint => 'Full Name';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get enterPassword => 'Please enter a password';

  @override
  String get passwordLength => 'Password must be at least 6 characters';

  @override
  String get confirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get enterEmailForReset => 'Please enter your email address';

  @override
  String get passwordResetSent => 'Password reset email sent';

  @override
  String get homeTab => 'Home';

  @override
  String get transactionsTab => 'Transactions';

  @override
  String get budgetsTab => 'Budgets';

  @override
  String get settingsTab => 'Settings';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get logout => 'Logout';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Spendora';

  @override
  String get onboardingWelcomeDescription => 'Take control of your finances with smart expense tracking and budgeting';

  @override
  String get onboardingCurrencyTitle => 'Select Your Currency';

  @override
  String get onboardingCurrencyDescription => 'Choose your preferred currency for transactions';

  @override
  String get onboardingCategoriesTitle => 'Default Categories';

  @override
  String get onboardingCategoriesDescription => 'We\'ve prepared some categories to get you started';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get monthlyOverview => 'Monthly Overview';

  @override
  String get expenses => 'Expenses';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get retry => 'Retry';

  @override
  String errorCalculatingConversion(String error) {
    return 'Error calculating conversion: $error';
  }

  @override
  String get seeAll => 'See All';

  @override
  String get thisMonth => 'This Month';

  @override
  String get viewAll => 'View All';

  @override
  String get transactions => 'Transactions';

  @override
  String get categoryTransactions => 'Category Transactions';

  @override
  String get resetToLast30Days => 'Reset to Last 30 Days';

  @override
  String get filterTransactions => 'Filter Transactions';

  @override
  String get allTransactions => 'All Transactions';

  @override
  String get recurringTransactions => 'Recurring Transactions';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get confirmDelete => 'Delete Transaction?';

  @override
  String get confirmDeleteMessage => 'Are you sure you want to delete this transaction? This action cannot be undone.';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get required => 'This field is required';

  @override
  String get invalidAmount => 'Please enter a valid amount';

  @override
  String get errorCreatingTransaction => 'Failed to create transaction';

  @override
  String errorLoadingCategories(String error) {
    return 'Error loading categories: $error';
  }

  @override
  String get errorLoadingTransaction => 'Failed to load transaction';

  @override
  String get errorUpdatingTransaction => 'Failed to update transaction';

  @override
  String get errorDeletingTransaction => 'Failed to delete transaction';

  @override
  String get transactionNotFound => 'Transaction not found';

  @override
  String get tags => 'Tags';

  @override
  String get recurring => 'Recurring';

  @override
  String get categories => 'Categories';

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String percentageOfTotalExpenses(String percentage) {
    return '$percentage% of total expenses';
  }

  @override
  String conversionDetails(String details) {
    return 'Converted from: $details';
  }

  @override
  String get noPreferencesFound => 'No preferences found';

  @override
  String get profile => 'Profile';

  @override
  String get preferences => 'Preferences';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get mainCurrency => 'Main Currency';

  @override
  String get currencyDisplay => 'Currency Display';

  @override
  String convertAllTo(String currency) {
    return 'Convert all to $currency';
  }

  @override
  String get groupByCurrency => 'Group by currency';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get manageTags => 'Manage Tags';

  @override
  String get account => 'Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get advanced => 'Advanced';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';
}

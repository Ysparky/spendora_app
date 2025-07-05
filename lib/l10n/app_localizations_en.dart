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
}

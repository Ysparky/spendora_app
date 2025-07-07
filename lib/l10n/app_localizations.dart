import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Spendora'**
  String get appName;

  /// Title shown on the login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// Text for the login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Title shown on the register screen
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// Text for the register button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// Hint text for full name input field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameHint;

  /// Hint text for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// Hint text for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// Hint text for confirm password input field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordHint;

  /// Text for forgot password button
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Text shown before register link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Text shown before login link
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Validation message for empty name
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// Validation message for empty email
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// Validation message for invalid email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// Validation message for empty password
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get enterPassword;

  /// Validation message for short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLength;

  /// Validation message for empty confirm password
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPassword;

  /// Validation message for non-matching passwords
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Message shown when trying to reset password without email
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get enterEmailForReset;

  /// Message shown after password reset email is sent
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetSent;

  /// Label for home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// Label for transactions tab
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTab;

  /// Label for budgets tab
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTab;

  /// Label for settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// Title for add transaction screen
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// Label for amount input
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Label for description input
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label for category selection
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Label for date selection
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Label for transaction type selection
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Label for income amount
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Label for expense type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Title for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label for currency field
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Label for theme selection
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Label for notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Label for logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Generic error message title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Generic success message title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Label for cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Label for delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title shown on the first onboarding page
  ///
  /// In en, this message translates to:
  /// **'Welcome to Spendora'**
  String get onboardingWelcomeTitle;

  /// Description shown on the first onboarding page
  ///
  /// In en, this message translates to:
  /// **'Take control of your finances with smart expense tracking and budgeting'**
  String get onboardingWelcomeDescription;

  /// Title shown on the currency selection page
  ///
  /// In en, this message translates to:
  /// **'Select Your Currency'**
  String get onboardingCurrencyTitle;

  /// Description shown on the currency selection page
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred currency for transactions'**
  String get onboardingCurrencyDescription;

  /// Title shown on the categories preview page
  ///
  /// In en, this message translates to:
  /// **'Default Categories'**
  String get onboardingCategoriesTitle;

  /// Description shown on the categories preview page
  ///
  /// In en, this message translates to:
  /// **'We\'ve prepared some categories to get you started'**
  String get onboardingCategoriesDescription;

  /// Text for the next button in onboarding
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Text for the final button in onboarding
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// Title shown on the dashboard screen
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Label for total balance section
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// Label for monthly overview section
  ///
  /// In en, this message translates to:
  /// **'Monthly Overview'**
  String get monthlyOverview;

  /// Label for expenses amount
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Label for top categories section
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategories;

  /// Label for recent transactions section
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Message shown when no data is available
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Label for retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error message shown when currency conversion fails
  ///
  /// In en, this message translates to:
  /// **'Error calculating conversion: {error}'**
  String errorCalculatingConversion(String error);

  /// Label for see all button
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Label for current month
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Label for view all button
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Title for the transactions list screen
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Title for transactions filtered by category
  ///
  /// In en, this message translates to:
  /// **'Category Transactions'**
  String get categoryTransactions;

  /// Tooltip for resetting date filter to last 30 days
  ///
  /// In en, this message translates to:
  /// **'Reset to Last 30 Days'**
  String get resetToLast30Days;

  /// Title for transaction filter dialog
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filterTransactions;

  /// Label for showing all transactions
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// Label for showing recurring transactions
  ///
  /// In en, this message translates to:
  /// **'Recurring Transactions'**
  String get recurringTransactions;

  /// Message shown when no transactions are available
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// Title for edit transaction screen
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// Title for transaction details screen
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction?'**
  String get confirmDelete;

  /// Message for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This action cannot be undone.'**
  String get confirmDeleteMessage;

  /// Label for date picker button
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Label for category picker button
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Validation message for required fields
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required;

  /// Validation message for invalid amount
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// Error message shown when transaction creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create transaction'**
  String get errorCreatingTransaction;

  /// Error message shown when loading categories fails
  ///
  /// In en, this message translates to:
  /// **'Error loading categories: {error}'**
  String errorLoadingCategories(String error);

  /// Error message shown when loading a transaction fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load transaction'**
  String get errorLoadingTransaction;

  /// Error message shown when updating a transaction fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update transaction'**
  String get errorUpdatingTransaction;

  /// Error message shown when deleting a transaction fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete transaction'**
  String get errorDeletingTransaction;

  /// Message shown when a transaction cannot be found
  ///
  /// In en, this message translates to:
  /// **'Transaction not found'**
  String get transactionNotFound;

  /// Label for transaction tags
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// Label for recurring transaction
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// Title for the categories overview screen
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Message shown when no categories are available
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// Label showing category percentage of total expenses
  ///
  /// In en, this message translates to:
  /// **'{percentage}% of total expenses'**
  String percentageOfTotalExpenses(String percentage);

  /// Label showing currency conversion details
  ///
  /// In en, this message translates to:
  /// **'Converted from: {details}'**
  String conversionDetails(String details);

  /// Message shown when no user preferences are found
  ///
  /// In en, this message translates to:
  /// **'No preferences found'**
  String get noPreferencesFound;

  /// Title for profile section
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Title for preferences section
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Label for dark mode toggle
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Label for main currency selection
  ///
  /// In en, this message translates to:
  /// **'Main Currency'**
  String get mainCurrency;

  /// Label for currency display mode
  ///
  /// In en, this message translates to:
  /// **'Currency Display'**
  String get currencyDisplay;

  /// Label for unified currency display mode
  ///
  /// In en, this message translates to:
  /// **'Convert all to {currency}'**
  String convertAllTo(String currency);

  /// Label for grouped currency display mode
  ///
  /// In en, this message translates to:
  /// **'Group by currency'**
  String get groupByCurrency;

  /// Title for data management section
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Label for categories management
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// Label for tags management
  ///
  /// In en, this message translates to:
  /// **'Manage Tags'**
  String get manageTags;

  /// Title for account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Label for sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Label for advanced settings
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Label for delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Title for edit profile dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Label for name field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Title for delete account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// Message for delete account confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountMessage;

  /// Error message shown when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String errorDeletingAccount(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

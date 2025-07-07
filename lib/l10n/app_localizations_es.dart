// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Spendora';

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get fullNameHint => 'Nombre completo';

  @override
  String get emailHint => 'Correo electrónico';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get confirmPasswordHint => 'Confirmar contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get enterName => 'Por favor, ingresa tu nombre';

  @override
  String get enterEmail => 'Por favor, ingresa tu correo electrónico';

  @override
  String get enterValidEmail =>
      'Por favor, ingresa un correo electrónico válido';

  @override
  String get enterPassword => 'Por favor, ingresa una contraseña';

  @override
  String get passwordLength => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get confirmPassword => 'Por favor, confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get enterEmailForReset => 'Por favor, ingresa tu correo electrónico';

  @override
  String get passwordResetSent =>
      'Se ha enviado el correo de restablecimiento de contraseña';

  @override
  String get homeTab => 'Inicio';

  @override
  String get transactionsTab => 'Transacciones';

  @override
  String get budgetsTab => 'Presupuestos';

  @override
  String get settingsTab => 'Ajustes';

  @override
  String get addTransaction => 'Agregar Transacción';

  @override
  String get amount => 'Monto';

  @override
  String get description => 'Descripción';

  @override
  String get category => 'Categoría';

  @override
  String get date => 'Fecha';

  @override
  String get type => 'Tipo';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gasto';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get currency => 'Moneda';

  @override
  String get theme => 'Tema';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Spendora';

  @override
  String get onboardingWelcomeDescription =>
      'Toma el control de tus finanzas con un seguimiento inteligente de gastos y presupuestos';

  @override
  String get onboardingCurrencyTitle => 'Selecciona tu moneda';

  @override
  String get onboardingCurrencyDescription =>
      'Elige tu moneda preferida para las transacciones';

  @override
  String get onboardingCategoriesTitle => 'Categorías predeterminadas';

  @override
  String get onboardingCategoriesDescription =>
      'Hemos preparado algunas categorías para empezar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingGetStarted => 'Comenzar';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get totalBalance => 'Balance total';

  @override
  String get monthlyOverview => 'Resumen mensual';

  @override
  String get expenses => 'Gastos';

  @override
  String get topCategories => 'Categorías principales';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get noDataAvailable => 'No hay datos disponibles';

  @override
  String get retry => 'Reintentar';

  @override
  String errorCalculatingConversion(String error) {
    return 'Error al calcular la conversión: $error';
  }

  @override
  String get seeAll => 'Ver todo';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get transactions => 'Transacciones';

  @override
  String get categoryTransactions => 'Transacciones por Categoría';

  @override
  String get resetToLast30Days => 'Últimos 30 días';

  @override
  String get filterTransactions => 'Filtrar Transacciones';

  @override
  String get allTransactions => 'Todas las Transacciones';

  @override
  String get recurringTransactions => 'Transacciones Recurrentes';

  @override
  String get noTransactionsFound => 'No se encontraron transacciones';

  @override
  String get editTransaction => 'Editar Transacción';

  @override
  String get transactionDetails => 'Detalles de la Transacción';

  @override
  String get confirmDelete => '¿Eliminar Transacción?';

  @override
  String get confirmDeleteMessage =>
      '¿Estás seguro de que deseas eliminar esta transacción? Esta acción no se puede deshacer.';

  @override
  String get selectDate => 'Seleccionar Fecha';

  @override
  String get selectCategory => 'Seleccionar Categoría';

  @override
  String get required => 'Este campo es obligatorio';

  @override
  String get invalidAmount => 'Por favor ingresa un monto válido';

  @override
  String get errorCreatingTransaction => 'Error al crear la transacción';

  @override
  String errorLoadingCategories(String error) {
    return 'Error al cargar las categorías: $error';
  }

  @override
  String get errorLoadingTransaction => 'Error al cargar la transacción';

  @override
  String get errorUpdatingTransaction => 'Error al actualizar la transacción';

  @override
  String get errorDeletingTransaction => 'Error al eliminar la transacción';

  @override
  String get transactionNotFound => 'Transacción no encontrada';

  @override
  String get tags => 'Etiquetas';

  @override
  String get recurring => 'Recurrente';

  @override
  String get categories => 'Categorías';

  @override
  String get noCategoriesFound => 'No se encontraron categorías';

  @override
  String percentageOfTotalExpenses(String percentage) {
    return '$percentage% del total de gastos';
  }

  @override
  String conversionDetails(String details) {
    return 'Convertido de: $details';
  }

  @override
  String get noPreferencesFound => 'No se encontraron preferencias';

  @override
  String get profile => 'Perfil';

  @override
  String get preferences => 'Preferencias';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get mainCurrency => 'Moneda principal';

  @override
  String get currencyDisplay => 'Visualización de moneda';

  @override
  String convertAllTo(String currency) {
    return 'Convertir todo a $currency';
  }

  @override
  String get groupByCurrency => 'Agrupar por moneda';

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get manageCategories => 'Gestionar categorías';

  @override
  String get manageTags => 'Gestionar etiquetas';

  @override
  String get account => 'Cuenta';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get advanced => 'Avanzado';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get name => 'Nombre';

  @override
  String get email => 'Correo electrónico';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountMessage =>
      '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.';

  @override
  String errorDeletingAccount(String error) =>
      'Error al eliminar la cuenta: $error';

  @override
  String get noTransactionsYet => 'Aún No Hay Transacciones';

  @override
  String get addTransactionToStart =>
      'Agrega tu primera transacción para comenzar a rastrear tus finanzas';
}

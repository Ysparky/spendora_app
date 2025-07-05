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
  String get enterValidEmail => 'Por favor, ingresa un correo electrónico válido';

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
  String get passwordResetSent => 'Se ha enviado el correo de restablecimiento de contraseña';

  @override
  String get homeTab => 'Inicio';

  @override
  String get transactionsTab => 'Transacciones';

  @override
  String get budgetsTab => 'Presupuestos';

  @override
  String get settingsTab => 'Ajustes';

  @override
  String get addTransaction => 'Añadir transacción';

  @override
  String get amount => 'Cantidad';

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
  String get onboardingWelcomeDescription => 'Toma el control de tus finanzas con un seguimiento inteligente de gastos y presupuestos';

  @override
  String get onboardingCurrencyTitle => 'Selecciona tu moneda';

  @override
  String get onboardingCurrencyDescription => 'Elige tu moneda preferida para las transacciones';

  @override
  String get onboardingCategoriesTitle => 'Categorías predeterminadas';

  @override
  String get onboardingCategoriesDescription => 'Hemos preparado algunas categorías para empezar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingGetStarted => 'Comenzar';
}

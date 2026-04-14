// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Easy Todo';

  @override
  String get loginWelcomeBack => 'Bienvenido de vuelta';

  @override
  String get loginCreateAccount => 'Crea tu cuenta';

  @override
  String get loginHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get loginNoAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get loginOr => 'o';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get emailEmptyError => 'Ingresa tu correo';

  @override
  String get emailInvalidError => 'Ingresa un correo válido';

  @override
  String get passwordEmptyError => 'Ingresa tu contraseña';

  @override
  String get passwordTooShortError =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get signUpButton => 'Crear cuenta';

  @override
  String get signInButton => 'Iniciar sesión';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get nameEmptyError => 'Ingresa tu nombre';

  @override
  String get usernameLabel => 'Nombre de usuario';

  @override
  String get usernameEmptyError => 'Ingresa un nombre de usuario';

  @override
  String get usernameTooShortError =>
      'El nombre de usuario debe tener al menos 3 caracteres';

  @override
  String get usernameInvalidError => 'Solo letras, números y guiones bajos';

  @override
  String get usernameChecking => 'Verificando...';

  @override
  String get usernameAvailable => 'Disponible';

  @override
  String get usernameTaken => 'Nombre de usuario no disponible';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get homeTitle => 'Mis Tareas';

  @override
  String get homeSectionToday => 'HOY';

  @override
  String get homeSectionUpcoming => 'SIGUIENTES';

  @override
  String get homeSectionCompleted => 'COMPLETADAS';

  @override
  String get homeEmptyTitle => 'No tienes tareas pendientes';

  @override
  String get homeEmptySubtitle => 'Toca + para agregar una nueva tarea';

  @override
  String get navHome => 'Inicio';

  @override
  String get navTeam => 'Equipo';

  @override
  String get navSettings => 'Config';

  @override
  String get taskTitleLabel => 'Título *';

  @override
  String get taskDescriptionLabel => 'Descripción (opcional)';

  @override
  String get taskPriorityLabel => 'Prioridad';

  @override
  String get taskPriorityLow => 'Baja';

  @override
  String get taskPriorityMedium => 'Media';

  @override
  String get taskPriorityHigh => 'Alta';

  @override
  String get taskNoDate => 'Sin fecha';

  @override
  String get taskScheduleNotification => 'Programar notificación';

  @override
  String taskNotificationAt(String time) {
    return 'Notificación a las $time';
  }

  @override
  String get addTaskButton => 'Agregar tarea';

  @override
  String get taskTitleRequired => 'El título es obligatorio';

  @override
  String get deleteTaskTitle => 'Eliminar tarea';

  @override
  String deleteTaskConfirm(String taskTitle) {
    return '¿Eliminar \"$taskTitle\"?';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get teamPageTitle => 'Equipo';

  @override
  String get teamNoTeamTitle => 'No perteneces a ningún equipo';

  @override
  String get teamNoTeamSubtitle =>
      'Crea un equipo nuevo o únete con un código de invitación.';

  @override
  String get teamCreateButton => 'Crear equipo';

  @override
  String get teamJoinButton => 'Unirse con código';

  @override
  String get teamEmptyTasksTitle => 'No hay tareas en el equipo';

  @override
  String get teamEmptyTasksSubtitle => 'Toca + para agregar la primera tarea';

  @override
  String get teamSectionMyTasks => 'MIS TAREAS';

  @override
  String get teamSectionUnassigned => 'SIN ASIGNAR';

  @override
  String get teamSectionOthers => 'OTROS MIEMBROS';

  @override
  String get teamSectionCompleted => 'COMPLETADAS';

  @override
  String get teamMenuInviteCode => 'Ver código de invitación';

  @override
  String get teamMenuLeave => 'Salir del equipo';

  @override
  String get teamAssignTaskTitle => 'Asignar tarea';

  @override
  String get teamAssignUnassigned => 'Sin asignar';

  @override
  String get teamRoleAdmin => 'Admin';

  @override
  String get teamAdminSuffix => ' (admin)';

  @override
  String get teamInviteCodeTitle => 'Código de invitación';

  @override
  String get teamInviteCodeDescription =>
      'Comparte este código para que otros se unan al equipo.';

  @override
  String get teamLeaveTitle => 'Salir del equipo';

  @override
  String get teamLeaveConfirm =>
      '¿Estás seguro de que quieres salir de este equipo?';

  @override
  String get teamLeaveButton => 'Salir';

  @override
  String get teamAssignTooltip => 'Asignar';

  @override
  String get createTeamTitle => 'Crear equipo';

  @override
  String get createTeamDescription =>
      'Crea un nuevo equipo y comparte el código de invitación con tus compañeros.';

  @override
  String get createTeamNameLabel => 'Nombre del equipo *';

  @override
  String get createTeamNameRequired => 'El nombre es obligatorio';

  @override
  String get createTeamButton => 'Crear equipo';

  @override
  String get joinTeamTitle => 'Unirse a un equipo';

  @override
  String get joinTeamDescription =>
      'Ingresa el código de 6 caracteres que te compartió el administrador del equipo.';

  @override
  String get joinTeamCodeLabel => 'Código de invitación *';

  @override
  String get joinTeamCodeHint => 'Ej: AB1C2D';

  @override
  String get joinTeamCodeRequired => 'El código es obligatorio';

  @override
  String get joinTeamCodeLength => 'El código debe tener 6 caracteres';

  @override
  String get joinTeamButton => 'Unirse al equipo';

  @override
  String get addTeamTaskTitle => 'Nueva tarea de equipo';

  @override
  String get teamTaskAssignLabel => 'Asignar a (opcional)';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsDefaultUser => 'Usuario';

  @override
  String get settingsNotificationsTitle => 'Notificaciones locales';

  @override
  String get settingsNotificationsSubtitle =>
      'Recordatorios de tareas con fecha';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeDesert => 'Desierto';

  @override
  String get settingsThemeForest => 'Bosque';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutConfirm =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get notificationChannelName => 'Easy Todo Notifications';

  @override
  String get notificationChannelDescription =>
      'Recordatorios de tareas pendientes';

  @override
  String notificationTitle(String taskTitle) {
    return 'Tarea pendiente: $taskTitle';
  }

  @override
  String get notificationDefaultBody => 'Tienes una tarea por completar';
}

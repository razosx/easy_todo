// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Easy Todo';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginCreateAccount => 'Create your account';

  @override
  String get loginHaveAccount => 'Already have an account? Sign in';

  @override
  String get loginNoAccount => 'Don\'t have an account? Sign up';

  @override
  String get loginOr => 'or';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailEmptyError => 'Enter your email';

  @override
  String get emailInvalidError => 'Enter a valid email';

  @override
  String get passwordEmptyError => 'Enter your password';

  @override
  String get passwordTooShortError => 'Password must be at least 6 characters';

  @override
  String get signUpButton => 'Create account';

  @override
  String get signInButton => 'Sign in';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameEmptyError => 'Enter your name';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameEmptyError => 'Enter a username';

  @override
  String get usernameTooShortError => 'Username must be at least 3 characters';

  @override
  String get usernameInvalidError => 'Only letters, numbers and underscores';

  @override
  String get usernameChecking => 'Checking...';

  @override
  String get usernameAvailable => 'Available';

  @override
  String get usernameTaken => 'Username already taken';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get homeTitle => 'My Tasks';

  @override
  String get homeSectionToday => 'TODAY';

  @override
  String get homeSectionUpcoming => 'UPCOMING';

  @override
  String get homeSectionCompleted => 'COMPLETED';

  @override
  String get homeEmptyTitle => 'No pending tasks';

  @override
  String get homeEmptySubtitle => 'Tap + to add a new task';

  @override
  String get navHome => 'Home';

  @override
  String get navTeam => 'Team';

  @override
  String get navSettings => 'Settings';

  @override
  String get taskTitleLabel => 'Title *';

  @override
  String get taskDescriptionLabel => 'Description (optional)';

  @override
  String get taskPriorityLabel => 'Priority';

  @override
  String get taskPriorityLow => 'Low';

  @override
  String get taskPriorityMedium => 'Medium';

  @override
  String get taskPriorityHigh => 'High';

  @override
  String get taskNoDate => 'No date';

  @override
  String get taskScheduleNotification => 'Schedule notification';

  @override
  String taskNotificationAt(String time) {
    return 'Notification at $time';
  }

  @override
  String get addTaskButton => 'Add task';

  @override
  String get taskTitleRequired => 'Title is required';

  @override
  String get deleteTaskTitle => 'Delete task';

  @override
  String deleteTaskConfirm(String taskTitle) {
    return 'Delete \"$taskTitle\"?';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get closeButton => 'Close';

  @override
  String get teamPageTitle => 'Team';

  @override
  String get teamNoTeamTitle => 'You don\'t belong to any team';

  @override
  String get teamNoTeamSubtitle =>
      'Create a new team or join with an invite code.';

  @override
  String get teamCreateButton => 'Create team';

  @override
  String get teamJoinButton => 'Join with code';

  @override
  String get teamEmptyTasksTitle => 'No tasks in the team';

  @override
  String get teamEmptyTasksSubtitle => 'Tap + to add the first task';

  @override
  String get teamSectionMyTasks => 'MY TASKS';

  @override
  String get teamSectionUnassigned => 'UNASSIGNED';

  @override
  String get teamSectionOthers => 'OTHER MEMBERS';

  @override
  String get teamSectionCompleted => 'COMPLETED';

  @override
  String get teamMenuInviteCode => 'View invite code';

  @override
  String get teamMenuLeave => 'Leave team';

  @override
  String get teamAssignTaskTitle => 'Assign task';

  @override
  String get teamAssignUnassigned => 'Unassigned';

  @override
  String get teamRoleAdmin => 'Admin';

  @override
  String get teamAdminSuffix => ' (admin)';

  @override
  String get teamInviteCodeTitle => 'Invite code';

  @override
  String get teamInviteCodeDescription =>
      'Share this code so others can join the team.';

  @override
  String get teamLeaveTitle => 'Leave team';

  @override
  String get teamLeaveConfirm => 'Are you sure you want to leave this team?';

  @override
  String get teamLeaveButton => 'Leave';

  @override
  String get teamAssignTooltip => 'Assign';

  @override
  String get createTeamTitle => 'Create team';

  @override
  String get createTeamDescription =>
      'Create a new team and share the invite code with your teammates.';

  @override
  String get createTeamNameLabel => 'Team name *';

  @override
  String get createTeamNameRequired => 'Name is required';

  @override
  String get createTeamButton => 'Create team';

  @override
  String get joinTeamTitle => 'Join a team';

  @override
  String get joinTeamDescription =>
      'Enter the 6-character code shared by the team admin.';

  @override
  String get joinTeamCodeLabel => 'Invite code *';

  @override
  String get joinTeamCodeHint => 'E.g.: AB1C2D';

  @override
  String get joinTeamCodeRequired => 'Code is required';

  @override
  String get joinTeamCodeLength => 'Code must be 6 characters';

  @override
  String get joinTeamButton => 'Join team';

  @override
  String get addTeamTaskTitle => 'New team task';

  @override
  String get teamTaskAssignLabel => 'Assign to (optional)';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDefaultUser => 'User';

  @override
  String get settingsNotificationsTitle => 'Local notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Reminders for tasks with a due date';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeDesert => 'Desert';

  @override
  String get settingsThemeForest => 'Forest';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLogout => 'Sign out';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get notificationChannelName => 'Easy Todo Notifications';

  @override
  String get notificationChannelDescription => 'Reminders for pending tasks';

  @override
  String notificationTitle(String taskTitle) {
    return 'Pending task: $taskTitle';
  }

  @override
  String get notificationDefaultBody => 'You have a task to complete';
}

// GENERATED — do not edit by hand.
// Run 'flutter gen-l10n' or 'make l10n' to regenerate.
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
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Easy Todo'**
  String get appTitle;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get loginCreateAccount;

  /// No description provided for @loginHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get loginHaveAccount;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get loginNoAccount;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOr;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @emailEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailEmptyError;

  /// No description provided for @emailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalidError;

  /// No description provided for @passwordEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordEmptyError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShortError;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameEmptyError;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter a username'**
  String get usernameEmptyError;

  /// No description provided for @usernameTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameTooShortError;

  /// No description provided for @usernameInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers and underscores'**
  String get usernameInvalidError;

  /// No description provided for @usernameChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get usernameChecking;

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get usernameAvailable;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username already taken'**
  String get usernameTaken;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpButton;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get homeTitle;

  /// No description provided for @homeSectionToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get homeSectionToday;

  /// No description provided for @homeSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get homeSectionUpcoming;

  /// No description provided for @homeSectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get homeSectionCompleted;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a new task'**
  String get homeEmptySubtitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get navTeam;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @taskTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get taskTitleLabel;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get taskDescriptionLabel;

  /// No description provided for @taskPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskPriorityLabel;

  /// No description provided for @taskPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get taskPriorityLow;

  /// No description provided for @taskPriorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get taskPriorityMedium;

  /// No description provided for @taskPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get taskPriorityHigh;

  /// No description provided for @taskNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get taskNoDate;

  /// No description provided for @taskScheduleNotification.
  ///
  /// In en, this message translates to:
  /// **'Schedule notification'**
  String get taskScheduleNotification;

  /// No description provided for @taskNotificationAt.
  ///
  /// In en, this message translates to:
  /// **'Notification at {time}'**
  String taskNotificationAt(String time);

  /// No description provided for @addTaskButton.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTaskButton;

  /// No description provided for @taskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get taskTitleRequired;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{taskTitle}\"?'**
  String deleteTaskConfirm(String taskTitle);

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @teamPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamPageTitle;

  /// No description provided for @teamNoTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t belong to any team'**
  String get teamNoTeamTitle;

  /// No description provided for @teamNoTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new team or join with an invite code.'**
  String get teamNoTeamSubtitle;

  /// No description provided for @teamCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get teamCreateButton;

  /// No description provided for @teamJoinButton.
  ///
  /// In en, this message translates to:
  /// **'Join with code'**
  String get teamJoinButton;

  /// No description provided for @teamEmptyTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks in the team'**
  String get teamEmptyTasksTitle;

  /// No description provided for @teamEmptyTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first task'**
  String get teamEmptyTasksSubtitle;

  /// No description provided for @teamSectionMyTasks.
  ///
  /// In en, this message translates to:
  /// **'MY TASKS'**
  String get teamSectionMyTasks;

  /// No description provided for @teamSectionUnassigned.
  ///
  /// In en, this message translates to:
  /// **'UNASSIGNED'**
  String get teamSectionUnassigned;

  /// No description provided for @teamSectionOthers.
  ///
  /// In en, this message translates to:
  /// **'OTHER MEMBERS'**
  String get teamSectionOthers;

  /// No description provided for @teamSectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get teamSectionCompleted;

  /// No description provided for @teamMenuInviteCode.
  ///
  /// In en, this message translates to:
  /// **'View invite code'**
  String get teamMenuInviteCode;

  /// No description provided for @teamMenuLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave team'**
  String get teamMenuLeave;

  /// No description provided for @teamAssignTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign task'**
  String get teamAssignTaskTitle;

  /// No description provided for @teamAssignUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get teamAssignUnassigned;

  /// No description provided for @teamRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get teamRoleAdmin;

  /// No description provided for @teamAdminSuffix.
  ///
  /// In en, this message translates to:
  /// **' (admin)'**
  String get teamAdminSuffix;

  /// No description provided for @teamInviteCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get teamInviteCodeTitle;

  /// No description provided for @teamInviteCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Share this code so others can join the team.'**
  String get teamInviteCodeDescription;

  /// No description provided for @teamLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave team'**
  String get teamLeaveTitle;

  /// No description provided for @teamLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this team?'**
  String get teamLeaveConfirm;

  /// No description provided for @teamLeaveButton.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get teamLeaveButton;

  /// No description provided for @teamAssignTooltip.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get teamAssignTooltip;

  /// No description provided for @createTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get createTeamTitle;

  /// No description provided for @createTeamDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a new team and share the invite code with your teammates.'**
  String get createTeamDescription;

  /// No description provided for @createTeamNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Team name *'**
  String get createTeamNameLabel;

  /// No description provided for @createTeamNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get createTeamNameRequired;

  /// No description provided for @createTeamButton.
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get createTeamButton;

  /// No description provided for @joinTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a team'**
  String get joinTeamTitle;

  /// No description provided for @joinTeamDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-character code shared by the team admin.'**
  String get joinTeamDescription;

  /// No description provided for @joinTeamCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code *'**
  String get joinTeamCodeLabel;

  /// No description provided for @joinTeamCodeHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: AB1C2D'**
  String get joinTeamCodeHint;

  /// No description provided for @joinTeamCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Code is required'**
  String get joinTeamCodeRequired;

  /// No description provided for @joinTeamCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 characters'**
  String get joinTeamCodeLength;

  /// No description provided for @joinTeamButton.
  ///
  /// In en, this message translates to:
  /// **'Join team'**
  String get joinTeamButton;

  /// No description provided for @addTeamTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New team task'**
  String get addTeamTaskTitle;

  /// No description provided for @teamTaskAssignLabel.
  ///
  /// In en, this message translates to:
  /// **'Assign to (optional)'**
  String get teamTaskAssignLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDefaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get settingsDefaultUser;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Local notifications'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders for tasks with a due date'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeDesert.
  ///
  /// In en, this message translates to:
  /// **'Desert'**
  String get settingsThemeDesert;

  /// No description provided for @settingsThemeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get settingsThemeForest;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsLogoutConfirm;

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Easy Todo Notifications'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders for pending tasks'**
  String get notificationChannelDescription;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending task: {taskTitle}'**
  String notificationTitle(String taskTitle);

  /// No description provided for @notificationDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'You have a task to complete'**
  String get notificationDefaultBody;
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

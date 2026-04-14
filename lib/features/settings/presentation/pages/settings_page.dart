import 'package:easy_todo/core/locale/locale_cubit.dart';
import 'package:easy_todo/core/notifications/local_notification_service.dart';
import 'package:easy_todo/core/theme/app_theme.dart';
import 'package:easy_todo/core/theme/theme_cubit.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_event.dart';
import 'package:easy_todo/features/auth/presentation/bloc/auth_state.dart';
import 'package:easy_todo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          final user = state.user;
          return ListView(
            children: [
              _ProfileSection(
                displayName: user.displayName,
                email: user.email,
                photoUrl: user.photoUrl,
              ),
              const Divider(),
              const _NotificationsSection(),
              const Divider(),
              const _ThemeSection(),
              const Divider(),
              const _LanguageSection(),
              const Divider(),
              _SessionSection(),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String? displayName;
  final String email;
  final String? photoUrl;

  const _ProfileSection({
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initial = (displayName?.isNotEmpty == true ? displayName! : email)
        .substring(0, 1)
        .toUpperCase();

    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
        child: photoUrl == null ? Text(initial, style: const TextStyle(fontSize: 20)) : null,
      ),
      title: Text(
        displayName ?? l10n.settingsDefaultUser,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(email),
    );
  }
}

class _NotificationsSection extends StatefulWidget {
  const _NotificationsSection();

  @override
  State<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<_NotificationsSection> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _enabled = prefs.getBool('notifications_enabled') ?? true);
    }
  }

  Future<void> _toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    if (!value && mounted) {
      await context.read<LocalNotificationService>().cancelAll();
    }
    if (mounted) setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SwitchListTile(
      title: Text(l10n.settingsNotificationsTitle),
      subtitle: Text(l10n.settingsNotificationsSubtitle),
      value: _enabled,
      onChanged: _toggle,
    );
  }
}

String _themeLabel(AppTheme t, AppLocalizations l10n) => switch (t) {
      AppTheme.system => l10n.settingsThemeSystem,
      AppTheme.light => l10n.settingsThemeLight,
      AppTheme.dark => l10n.settingsThemeDark,
      AppTheme.desierto => l10n.settingsThemeDesert,
      AppTheme.bosque => l10n.settingsThemeForest,
    };

class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ThemeCubit, AppTheme>(
      builder: (context, appTheme) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: Text(l10n.settingsThemeTitle),
              trailing: DropdownButton<AppTheme>(
                value: appTheme,
                underline: const SizedBox.shrink(),
                onChanged: (t) =>
                    context.read<ThemeCubit>().setTheme(t!),
                items: AppTheme.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(_themeLabel(t, l10n)),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 72, right: 16, bottom: 12),
              child: _ThemeColorPreview(appTheme: appTheme),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeColorPreview extends StatelessWidget {
  final AppTheme appTheme;

  const _ThemeColorPreview({required this.appTheme});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colors = [cs.primary, cs.secondary, cs.tertiary];
    return Row(
      children: colors.map((c) {
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: CircleAvatar(radius: 10, backgroundColor: c),
        );
      }).toList(),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.settingsLanguageTitle),
          trailing: DropdownButton<String>(
            value: locale.languageCode,
            underline: const SizedBox.shrink(),
            onChanged: (code) =>
                context.read<LocaleCubit>().setLocale(Locale(code!)),
            items: const [
              DropdownMenuItem(value: 'es', child: Text('Español')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
          ),
        );
      },
    );
  }
}

class _SessionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: Text(l10n.settingsLogout, style: const TextStyle(color: Colors.red)),
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.settingsLogout),
            content: Text(l10n.settingsLogoutConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancelButton),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AuthBloc>().add(SignOutRequested());
                },
                child: Text(l10n.settingsLogout,
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }
}

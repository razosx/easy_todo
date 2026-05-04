import 'package:easy_todo/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<AppTheme> {
  static const _key = 'app_theme';

  ThemeCubit() : super(AppTheme.system);

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    emit(_fromString(prefs.getString(_key)));
  }

  Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toString(theme));
    emit(theme);
  }

  static AppTheme _fromString(String? value) => switch (value) {
    'light' => AppTheme.light,
    'dark' => AppTheme.dark,
    'desierto' => AppTheme.desierto,
    'bosque' => AppTheme.bosque,
    _ => AppTheme.system,
  };

  static String _toString(AppTheme theme) => switch (theme) {
    AppTheme.light => 'light',
    AppTheme.dark => 'dark',
    AppTheme.desierto => 'desierto',
    AppTheme.bosque => 'bosque',
    _ => 'system',
  };
}

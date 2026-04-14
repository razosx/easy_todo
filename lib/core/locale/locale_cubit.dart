import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const _key = 'app_locale';
  static const _supported = ['en', 'es'];

  LocaleCubit() : super(const Locale('en'));

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && _supported.contains(code)) {
      emit(Locale(code));
    } else {
      final deviceCode =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      emit(Locale(_supported.contains(deviceCode) ? deviceCode : 'en'));
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    emit(locale);
  }
}

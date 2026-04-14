import 'package:flutter/material.dart';

enum AppTheme {
  system,   // DeepPurple, sigue preferencia del SO
  light,    // DeepPurple claro forzado
  dark,     // DeepPurple oscuro forzado
  desierto, // Paleta tierra/dorado, sigue SO
  bosque,   // Paleta verde/morado, sigue SO
}

class AppThemeData {
  AppThemeData._();

  // ── ThemeMode mapping ────────────────────────────────────────────────────
  static ThemeMode themeMode(AppTheme t) => switch (t) {
        AppTheme.light => ThemeMode.light,
        AppTheme.dark => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  // ── ThemeData claro ──────────────────────────────────────────────────────
  static ThemeData light(AppTheme t) {
    final cs = _lightColorScheme(t);
    return _buildThemeData(cs);
  }

  // ── ThemeData oscuro ─────────────────────────────────────────────────────
  static ThemeData dark(AppTheme t) {
    final cs = _darkColorScheme(t);
    return _buildThemeData(cs);
  }

  // ── ColorSchemes claros ──────────────────────────────────────────────────
  static ColorScheme _lightColorScheme(AppTheme t) {
    switch (t) {
      case AppTheme.desierto:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF539EE0),
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFFE0AA53),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFF5DFA5),
          onPrimaryContainer: const Color(0xFF3D2E00),
          secondary: const Color(0xFF6484A1),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFCCDEF0),
          tertiary: const Color(0xFF8B7C62),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFDDD0BC),
          surface: const Color(0xFFFDF8F2),
          onSurface: const Color(0xFF1E1A14),
          surfaceContainerHighest: const Color(0xFFF2EBE0),
          outline: const Color(0xFF545B61),
        );

      case AppTheme.bosque:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFD273DB),
          brightness: Brightness.light,
        ).copyWith(
          // #A9DE7C es demasiado claro como primary con texto blanco;
          // se usa una versión más oscura para cumplir contraste WCAG AA.
          primary: const Color(0xFF6B9E3A),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFA9DE7C),
          onPrimaryContainer: const Color(0xFF1A3300),
          secondary: const Color(0xFF99799C),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFE8D5EB),
          tertiary: const Color(0xFF7C8674),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFD0D9C8),
          surface: const Color(0xFFF5FBF0),
          onSurface: const Color(0xFF141E10),
          surfaceContainerHighest: const Color(0xFFEBF2E4),
          outline: const Color(0xFF5A475C),
        );

      default:
        // system / light / dark → deepPurple por defecto
        return ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        );
    }
  }

  // ── ColorSchemes oscuros ─────────────────────────────────────────────────
  static ColorScheme _darkColorScheme(AppTheme t) {
    switch (t) {
      case AppTheme.desierto:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF539EE0),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFE0AA53),
          onPrimary: const Color(0xFF3D2E00),
          primaryContainer: const Color(0xFF5A4200),
          onPrimaryContainer: const Color(0xFFF5DFA5),
          secondary: const Color(0xFF8AAECA),
          onSecondary: const Color(0xFF0D2535),
          secondaryContainer: const Color(0xFF2C4A5E),
          tertiary: const Color(0xFFBAAA92),
          onTertiary: const Color(0xFF2A2118),
          surface: const Color(0xFF3D3830),
          onSurface: const Color(0xFFF0E8DC),
          surfaceContainerHighest: const Color(0xFF4A453E),
          outline: const Color(0xFF8A8D8F),
        );

      case AppTheme.bosque:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFFD273DB),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFA9DE7C),
          onPrimary: const Color(0xFF28331F),
          primaryContainer: const Color(0xFF3E5C28),
          onPrimaryContainer: const Color(0xFFC5F099),
          secondary: const Color(0xFFCCA8CF),
          onSecondary: const Color(0xFF3A2040),
          secondaryContainer: const Color(0xFF5A3D5E),
          tertiary: const Color(0xFFB0BCA8),
          onTertiary: const Color(0xFF222E1E),
          surface: const Color(0xFF28331F),
          onSurface: const Color(0xFFE8F5DC),
          surfaceContainerHighest: const Color(0xFF303D28),
          outline: const Color(0xFF8A9080),
        );

      default:
        return ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        );
    }
  }

  // ── ThemeData compartido ─────────────────────────────────────────────────
  static ThemeData _buildThemeData(ColorScheme cs) {
    return ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: cs.secondaryContainer,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? cs.primary : null,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? cs.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.primaryContainer
              : null,
        ),
      ),
    );
  }
}

import 'package:easy_todo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppThemeData.themeMode', () {
    test('system → ThemeMode.system', () {
      expect(AppThemeData.themeMode(AppTheme.system), ThemeMode.system);
    });

    test('light → ThemeMode.light', () {
      expect(AppThemeData.themeMode(AppTheme.light), ThemeMode.light);
    });

    test('dark → ThemeMode.dark', () {
      expect(AppThemeData.themeMode(AppTheme.dark), ThemeMode.dark);
    });

    test('desierto → ThemeMode.system (respeta preferencia del SO)', () {
      expect(AppThemeData.themeMode(AppTheme.desierto), ThemeMode.system);
    });

    test('bosque → ThemeMode.system (respeta preferencia del SO)', () {
      expect(AppThemeData.themeMode(AppTheme.bosque), ThemeMode.system);
    });
  });

  group('AppThemeData.light — tema Desierto', () {
    late ThemeData theme;

    setUpAll(() {
      theme = AppThemeData.light(AppTheme.desierto);
    });

    test('primary es #E0AA53 (dorado)', () {
      expect(theme.colorScheme.primary, const Color(0xFFE0AA53));
    });

    test('secondary es #6484A1 (azul acerado)', () {
      expect(theme.colorScheme.secondary, const Color(0xFF6484A1));
    });

    test('tertiary es #8B7C62 (marrón cálido)', () {
      expect(theme.colorScheme.tertiary, const Color(0xFF8B7C62));
    });

    test('usa Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });
  });

  group('AppThemeData.dark — tema Desierto', () {
    late ThemeData theme;

    setUpAll(() {
      theme = AppThemeData.dark(AppTheme.desierto);
    });

    test('surface es #3D3830 (fondo oscuro cálido)', () {
      expect(theme.colorScheme.surface, const Color(0xFF3D3830));
    });

    test('primary se mantiene dorado en oscuro', () {
      expect(theme.colorScheme.primary, const Color(0xFFE0AA53));
    });
  });

  group('AppThemeData.light — tema Bosque', () {
    late ThemeData theme;

    setUpAll(() {
      theme = AppThemeData.light(AppTheme.bosque);
    });

    test('primary es #6B9E3A (verde oscuro con contraste)', () {
      expect(theme.colorScheme.primary, const Color(0xFF6B9E3A));
    });

    test('primaryContainer contiene el verde original #A9DE7C', () {
      expect(theme.colorScheme.primaryContainer, const Color(0xFFA9DE7C));
    });

    test('secondary es #99799C (lavanda)', () {
      expect(theme.colorScheme.secondary, const Color(0xFF99799C));
    });
  });

  group('AppThemeData.dark — tema Bosque', () {
    late ThemeData theme;

    setUpAll(() {
      theme = AppThemeData.dark(AppTheme.bosque);
    });

    test('surface es #28331F (fondo verde oscuro)', () {
      expect(theme.colorScheme.surface, const Color(0xFF28331F));
    });

    test('primary es #A9DE7C (verde claro visible en oscuro)', () {
      expect(theme.colorScheme.primary, const Color(0xFFA9DE7C));
    });
  });

  group('AppThemeData — temas por defecto', () {
    test('light(system) usa deepPurple como seed', () {
      final theme = AppThemeData.light(AppTheme.system);
      expect(theme.useMaterial3, isTrue);
      // El primary generado por deepPurple no es blanco ni negro
      expect(theme.colorScheme.primary, isNot(Colors.white));
      expect(theme.colorScheme.primary, isNot(Colors.black));
    });

    test('dark(dark) genera un ColorScheme oscuro', () {
      final theme = AppThemeData.dark(AppTheme.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });
  });
}

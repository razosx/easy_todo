# Plan: Temas personalizados — Desierto y Bosque
**Fecha de creación:** 2026-04-13
**Estado:** COMPLETADO

---

## Context

La app usa actualmente un `ThemeCubit` que emite `ThemeMode` (system/light/dark) y aplica siempre el mismo color seed `Colors.deepPurple`. El usuario quiere agregar dos paletas personalizadas extraídas de imágenes de referencia, de modo que la sección de Configuración ofrezca cinco opciones de tema. Los temas custom deben respetar el modo claro/oscuro del sistema igual que los temas por defecto.

---

## Paletas de color

### Tema Desierto
| Rol | Hex | Uso |
|-----|-----|-----|
| Primary | `#E0AA53` | AppBar, FAB, botones filled |
| Secondary | `#6484A1` | Chips, badges, secciones |
| Seed / Accent | `#539EE0` | Generación de tones Material 3 |
| Tertiary | `#8B7C62` | Iconos terciarios, subtítulos |
| Neutral | `#545B61` | Bordes, variantes de surface |
| Dark surface | `#3D3830` | Background en modo oscuro |

### Tema Bosque
| Rol | Hex | Uso |
|-----|-----|-----|
| Primary | `#A9DE7C` | AppBar, FAB, botones filled |
| Secondary | `#99799C` | Chips, badges, secciones |
| Seed / Accent | `#D273DB` | Generación de tones Material 3 |
| Tertiary | `#7C8674` | Iconos terciarios, subtítulos |
| Neutral | `#5A475C` | Bordes, variantes de surface |
| Dark surface | `#28331F` | Background en modo oscuro |

---

## Archivos críticos a modificar

| Archivo | Cambio |
|---------|--------|
| `lib/core/theme/theme_cubit.dart` | Reemplazar `ThemeMode` por `AppTheme` enum |
| `lib/core/theme/app_theme.dart` | **NUEVO** — enum + factory de ThemeData |
| `lib/app.dart` | Actualizar `BlocBuilder` + `_buildTheme()` |
| `lib/features/settings/presentation/pages/settings_page.dart` | Reemplazar `DropdownButton<ThemeMode>` |
| `test/features/settings/presentation/pages/settings_page_test.dart` | Ajustar mocks/stubs de ThemeCubit |

---

## Fase 1 — Enum `AppTheme` y utilidades (nuevo archivo)

**Crear:** `lib/core/theme/app_theme.dart`

```
enum AppTheme {
  system,    // DeepPurple, sigue preferencia del SO
  light,     // DeepPurple claro forzado
  dark,      // DeepPurple oscuro forzado
  desierto,  // Paleta tierra/dorado, sigue SO
  bosque,    // Paleta verde/morado, sigue SO
}
```

En el mismo archivo, clase `AppThemeData` con métodos estáticos:

```
static ThemeData light(AppTheme t)   → ThemeData modo claro para t
static ThemeData dark(AppTheme t)    → ThemeData modo oscuro para t
static ThemeMode themeMode(AppTheme t) → ThemeMode para MaterialApp
static String label(AppTheme t)      → Etiqueta en español (para UI)
```

### Construcción de ColorScheme

Para cada tema custom se usa `ColorScheme.fromSeed()` con el color seed de la paleta y luego `copyWith()` para fijar los colores específicos:

**Desierto light:**
```dart
ColorScheme.fromSeed(seedColor: Color(0xFF539EE0), brightness: Brightness.light)
  .copyWith(
    primary: Color(0xFFE0AA53),
    onPrimary: Colors.white,
    secondary: Color(0xFF6484A1),
    onSecondary: Colors.white,
    tertiary: Color(0xFF8B7C62),
    surfaceContainerHighest: Color(0xFFF2EBE0),
  )
```

**Desierto dark:**
```dart
ColorScheme.fromSeed(seedColor: Color(0xFF539EE0), brightness: Brightness.dark)
  .copyWith(
    primary: Color(0xFFE0AA53),
    secondary: Color(0xFF6484A1),
    tertiary: Color(0xFF8B7C62),
    surface: Color(0xFF3D3830),
    onSurface: Color(0xFFF0E8DC),
    surfaceContainerHighest: Color(0xFF4A453E),
  )
```

**Bosque light:**
```dart
ColorScheme.fromSeed(seedColor: Color(0xFFD273DB), brightness: Brightness.light)
  .copyWith(
    primary: Color(0xFF6B9E3A),       // versión más oscura de #A9DE7C para contraste
    onPrimary: Colors.white,
    secondary: Color(0xFF99799C),
    tertiary: Color(0xFF7C8674),
    surfaceContainerHighest: Color(0xFFEBF2E4),
  )
```
> Nota: `#A9DE7C` es muy claro para usar como primary directo (texto blanco sería ilegible). Se oscurece al `#6B9E3A` para cumplir ratio de contraste WCAG AA. El color original se puede usar en chips, badges y como `primaryContainer`.

**Bosque dark:**
```dart
ColorScheme.fromSeed(seedColor: Color(0xFFD273DB), brightness: Brightness.dark)
  .copyWith(
    primary: Color(0xFFA9DE7C),       // en modo oscuro sí tiene contraste
    onPrimary: Color(0xFF28331F),
    secondary: Color(0xFF99799C),
    tertiary: Color(0xFF7C8674),
    surface: Color(0xFF28331F),
    onSurface: Color(0xFFE8F5DC),
    surfaceContainerHighest: Color(0xFF303D28),
  )
```

### ThemeData completo (aplicado a todos los temas)

Cada `ThemeData` incluye:
```dart
ThemeData(
  colorScheme: colorScheme,
  useMaterial3: true,
  appBarTheme: AppBarTheme(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.onPrimary,
    elevation: 0,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.onPrimary,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    color: colorScheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  navigationBarTheme: NavigationBarThemeData(
    indicatorColor: colorScheme.secondaryContainer,
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? colorScheme.primary : null),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? colorScheme.primary : null),
    trackColor: WidgetStateProperty.resolveWith((s) =>
        s.contains(WidgetState.selected) ? colorScheme.primaryContainer : null),
  ),
)
```

### `themeMode` mapping
```
AppTheme.system   → ThemeMode.system
AppTheme.light    → ThemeMode.light
AppTheme.dark     → ThemeMode.dark
AppTheme.desierto → ThemeMode.system   (respeta preferencia del SO)
AppTheme.bosque   → ThemeMode.system
```

---

## Fase 2 — Refactorizar `ThemeCubit`

**Archivo:** `lib/core/theme/theme_cubit.dart`

- Cambiar `extends Cubit<ThemeMode>` → `extends Cubit<AppTheme>`
- Persistencia en `SharedPreferences` con la clave `'app_theme'`
- Mapa string ↔ `AppTheme`:
  ```
  'system'   ↔ AppTheme.system
  'light'    ↔ AppTheme.light
  'dark'     ↔ AppTheme.dark
  'desierto' ↔ AppTheme.desierto
  'bosque'   ↔ AppTheme.bosque
  ```
- Método `setTheme(AppTheme)` reemplaza `setTheme(ThemeMode)`
- Default en `_fromString` sigue siendo `AppTheme.system`

---

## Fase 3 — Integrar en `app.dart`

**Archivo:** `lib/app.dart`

Eliminar `_buildLightTheme()` y `_buildDarkTheme()`. Reemplazar `BlocBuilder<ThemeCubit, ThemeMode>` por `BlocBuilder<ThemeCubit, AppTheme>`:

```dart
BlocBuilder<ThemeCubit, AppTheme>(
  builder: (context, appTheme) {
    return MaterialApp.router(
      title: 'Easy Todo',
      debugShowCheckedModeBanner: false,
      theme: AppThemeData.light(appTheme),
      darkTheme: AppThemeData.dark(appTheme),
      themeMode: AppThemeData.themeMode(appTheme),
      routerConfig: _appRouter.router,
    );
  },
)
```

> Siempre se pasan `theme` y `darkTheme`. Para los temas custom con `ThemeMode.system`, Flutter elegirá automáticamente cuál usar según la preferencia del dispositivo.

---

## Fase 4 — Settings UI

**Archivo:** `lib/features/settings/presentation/pages/settings_page.dart`

Reemplazar `_ThemeSection` para usar `AppTheme` en lugar de `ThemeMode`:

- Cambiar `BlocBuilder<ThemeCubit, ThemeMode>` → `BlocBuilder<ThemeCubit, AppTheme>`
- Cambiar `DropdownButton<ThemeMode>` → `DropdownButton<AppTheme>`
- Items del dropdown generados con `AppTheme.values.map(...)` + `AppThemeData.label(t)`
- Icono del `ListTile`: `Icons.palette_outlined`
- `_ThemeColorPreview`: Row de 3 `CircleAvatar` mostrando primary/secondary/tertiary del tema activo

---

## Fase 5 — Tests

**Archivo:** `test/features/settings/presentation/pages/settings_page_test.dart`
- Test: `'shows theme dropdown with all 5 options'`
- Test: `'selecting Desierto emits AppTheme.desierto'`

**Archivo nuevo:** `test/core/theme/app_theme_test.dart`
- 13 tests cubriendo: themeMode mappings (×5), labels en español (×5), colores Desierto light/dark, colores Bosque light/dark

---

## Verificación end-to-end

1. `flutter test` — 128 tests pasando
2. `flutter run` en Android — navegar a Configuración, cambiar a "Desierto": AppBar debe volverse dorado (`#E0AA53`), cards con tono cálido
3. Cambiar a "Bosque": AppBar con verde oscuro (`#6B9E3A` light / `#A9DE7C` dark)
4. Activar modo oscuro del SO con "Desierto" activo → background oscuro `#3D3830`
5. Activar modo oscuro con "Bosque" activo → background oscuro `#28331F`
6. Cerrar y reabrir app → tema persiste correctamente

---

## Resultado

- **128 tests pasando** (107 previos + 13 unitarios de AppThemeData + 2 widget tests nuevos en settings + 6 existentes de settings)
- Archivos nuevos: `lib/core/theme/app_theme.dart`, `test/core/theme/app_theme_test.dart`
- Archivos modificados: `theme_cubit.dart`, `app.dart`, `settings_page.dart`, `settings_page_test.dart`

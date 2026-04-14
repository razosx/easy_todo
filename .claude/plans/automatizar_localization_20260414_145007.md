# Plan: Automatizar la creación de Localización

## Contexto

El proyecto ya tiene `generate: true` en `pubspec.yaml` y `l10n.yaml` configurado correctamente.
Esto significa que **Flutter genera automáticamente** los archivos Dart desde los `.arb` al correr
`flutter run` o `flutter build`.

**Problema actual**: Los archivos Dart (`app_localizations*.dart`) se están editando a mano en lugar
de editar los `.arb` y dejar que el toolchain genere el código. Esto rompe el flujo y genera
inconsistencias (los strings de username/name están en los Dart pero NO en los `.arb`).

**Flujo correcto**:
```
Editar app_en.arb + app_es.arb
        ↓
flutter gen-l10n   (o flutter run/build)
        ↓
app_localizations.dart  ← GENERADO, nunca editar a mano
app_localizations_en.dart ← GENERADO
app_localizations_es.dart ← GENERADO
```

---

## Phase 1: Sincronizar el estado actual [✓]

> Agregar al `.arb` los strings que hoy solo existen en los Dart files, y regenerar los archivos
> para que el toolchain sea la única fuente de verdad.

- [✓] 1. Agregar a `app_en.arb` los strings faltantes: `nameLabel`, `nameEmptyError`,
         `usernameLabel`, `usernameEmptyError`, `usernameTooShortError`, `usernameInvalidError`,
         `usernameChecking`, `usernameAvailable`, `usernameTaken`.
- [✓] 2. Agregar las traducciones correspondientes a `app_es.arb`.
- [✓] 3. Eliminar de los tres archivos Dart los getters añadidos manualmente.
- [✓] 4. Correr `flutter gen-l10n` para regenerar los archivos Dart desde los `.arb`.
- [✓] 5. Verificar que la app compila sin errores: `flutter build apk --debug`.

---

## Phase 2: Agregar `// GENERATED` al encabezado de los Dart y protegerlos en `.gitattributes` [✓]

> Marcar claramente que los Dart de l10n son generados y no deben editarse manualmente.

- [✓] 1. Agregar `l10n.yaml` la opción `header: "// GENERATED — do not edit by hand."` para
         que Flutter inserte el encabezado al regenerar.
- [✓] 2. Agregar al `.gitattributes` una regla para que los archivos generados se marquen como
         `linguist-generated=true` en GitHub y se excluyan de diffs por defecto:
         ```
         lib/l10n/app_localizations*.dart linguist-generated=true
         ```
- [✓] 3. Verificar que `flutter gen-l10n` respeta el header y que el diff en GitHub omite los
         archivos generados.

---

## Phase 3: Script helper para agregar strings nuevos [✓]

> Crear un script `scripts/add_l10n.sh` que automatice agregar una clave nueva a ambos `.arb`
> a la vez y regenere los Dart.

- [✓] 1. Crear el directorio `scripts/`.
- [✓] 2. Escribir `scripts/add_l10n.sh` con la siguiente interfaz:
         ```bash
         ./scripts/add_l10n.sh <key> "<en_value>" "<es_value>"
         # Ejemplo:
         # ./scripts/add_l10n.sh profileTitle "Profile" "Perfil"
         ```
         El script debe:
         - Insertar la clave antes del último `}` en ambos `.arb`.
         - Ejecutar `flutter gen-l10n`.
         - Imprimir un resumen de lo agregado.
- [✓] 3. Darle permisos de ejecución: `chmod +x scripts/add_l10n.sh`.
- [✓] 4. Probar el script agregando una clave de prueba y verificando que los Dart se actualizan.
- [✓] 5. Eliminar la clave de prueba.

---

## Phase 4: Makefile con targets de localización [ ]

> Exponer comandos simples en un `Makefile` para que cualquier desarrollador pueda regenerar
> o verificar las traducciones con un solo comando.

- [ ] 1. Crear (o actualizar) el `Makefile` en la raíz del proyecto con los targets:

  ```makefile
  # Regenerar archivos Dart desde los .arb
  l10n:
      flutter gen-l10n

  # Verificar que todos los keys de app_en.arb existen en app_es.arb
  l10n-check:
      dart scripts/check_l10n.dart

  # Agregar un string nuevo (uso: make l10n-add KEY=foo EN="Foo" ES="Foo es")
  l10n-add:
      ./scripts/add_l10n.sh $(KEY) "$(EN)" "$(ES)"
  ```

- [ ] 2. Documentar los targets en el README bajo una sección "Localization".

---

## Phase 5: Pre-commit hook para validar sincronía [ ]

> Evitar que alguien suba un commit donde los `.arb` y los Dart estén desfasados o donde se
> hayan editado los Dart a mano.

- [ ] 1. Crear `scripts/check_l10n.dart`: script Dart que lee `app_en.arb` y verifica que cada
         key exista también en `app_es.arb`. Sale con código de error si falta alguno.
- [ ] 2. Crear `.git/hooks/pre-commit` (o usar `lefthook`/`husky` si ya está configurado):
         ```bash
         #!/bin/sh
         dart scripts/check_l10n.dart || exit 1
         ```
- [ ] 3. Asegurarse de que el hook sea ejecutable: `chmod +x .git/hooks/pre-commit`.
- [ ] 4. Probar el hook quitando un key de `app_es.arb` y verificando que el commit falla con
         mensaje claro.
- [ ] 5. Restaurar el key eliminado en la prueba.

---

## Resultado esperado

- Los archivos `app_localizations*.dart` **nunca se editan a mano**.
- Agregar un string nuevo = editar los dos `.arb` (o usar `make l10n-add`) + `make l10n`.
- El pre-commit hook garantiza que `en` y `es` siempre estén sincronizados.
- El README documenta el flujo completo para nuevos colaboradores.

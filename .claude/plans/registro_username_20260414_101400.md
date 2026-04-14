# Plan: Mejorar Registro de Cuenta con Nombre, Username y Actualización de Vistas

## Contexto del Código Actual

- **`UserEntity`**: tiene `id`, `email`, `displayName?`, `photoUrl?` — falta `username` y `name`
- **`signUpWithEmail`**: solo acepta `email` + `password`
- **`EmailSignInForm`**: solo muestra campos email/password
- **`TeamMemberEntity`**: solo tiene `userId`, `role`, `joinedAt` — no guarda username para mostrar
- **`AddTeamTaskBottomSheet`**: el dropdown muestra `e.key` (userId) como texto
- **`_showAssignDialog`** en `team_tasks_page.dart`: muestra `e.key` (userId) en la lista
- **`SettingsPage`**: muestra `displayName` + `email` — no muestra username
- **Backend**: Firebase Auth + Firestore — no existe colección `users` aún

---

## Phase 1: Capa de Dominio [ ]
### Agregar `username` y `name` a las entidades y casos de uso del dominio.

1. [ ] Agregar campos `username` y `name` a `UserEntity` (`lib/features/auth/domain/entities/user_entity.dart`)
2. [ ] Actualizar `AuthRepository` para que `signUpWithEmail` acepte `name` y `username` (`lib/features/auth/domain/repositories/auth_repository.dart`)
3. [ ] Crear caso de uso `CheckUsernameAvailable` que consulte Firestore si el username ya existe (`lib/features/auth/domain/usecases/check_username_available.dart`)
4. [ ] Actualizar `SignUpWithEmailParams` para incluir `name` y `username` en `sign_up_with_email.dart`
5. [ ] Agregar campo `username` a `TeamMemberEntity` (`lib/features/team_tasks/domain/entities/team_member_entity.dart`)

---

## Phase 2: Capa de Datos [ ]
### Actualizar modelos, data sources y repositorios para persistir y leer username/name en Firestore.

1. [ ] Actualizar `UserModel` para incluir `username` y `name`: agregar a `toMap()`, `fromMap()` y `fromFirebaseUser()` (`lib/features/auth/data/models/user_model.dart`)
2. [ ] Actualizar `AuthRemoteDataSource` — el método `signUpWithEmail` debe:
   - Crear el usuario en Firebase Auth
   - Actualizar `displayName` en Firebase Auth con el `name`
   - Guardar documento en Firestore `/users/{uid}` con `{ id, email, name, username, photoUrl }`
   (`lib/features/auth/data/datasources/auth_remote_data_source.dart`)
3. [ ] Agregar método `checkUsernameAvailable(String username)` al data source que consulte Firestore `users` por el campo `username`
4. [ ] Actualizar `authStateChanges` y `currentUser` para leer el perfil completo desde Firestore `/users/{uid}` en lugar de solo Firebase Auth
5. [ ] Actualizar `AuthRepositoryImpl` para propagar `name` y `username` en `signUpWithEmail` (`lib/features/auth/data/repositories/auth_repository_impl.dart`)
6. [ ] Actualizar `TeamMemberModel` para serializar/deserializar el campo `username` (`lib/features/team_tasks/data/models/team_model.dart`)
7. [ ] Actualizar `TeamRemoteDataSource` — al hacer join, guardar el `username` del usuario en el documento del miembro del equipo en Firestore (`lib/features/team_tasks/data/datasources/team_remote_data_source.dart`)

---

## Phase 3: BLoC de Autenticación [ ]
### Actualizar eventos, estados y lógica del AuthBloc para manejar los nuevos campos.

1. [ ] Actualizar `SignUpWithEmailRequested` para incluir `name` y `username` (`lib/features/auth/presentation/bloc/auth_event.dart`)
2. [ ] Actualizar `AuthBloc` — pasar `name` y `username` al use case `SignUpWithEmail` (`lib/features/auth/presentation/bloc/auth_bloc.dart`)
3. [ ] Verificar que `AuthAuthenticated` expone el `UserEntity` con los nuevos campos (ya lo hace, solo verificar que llegan correctamente)

---

## Phase 4: UI — Formulario de Registro [ ]
### Agregar campos de nombre y username al formulario de registro con validación en tiempo real.

1. [ ] Agregar `TextEditingController` para `name` y `username` en `_EmailSignInFormState` (`lib/features/auth/presentation/widgets/email_sign_in_form.dart`)
2. [ ] Mostrar campo **Nombre** (`name`) solo cuando `isSignUp == true`, con validación de no vacío
3. [ ] Mostrar campo **Usuario** (`username`) solo cuando `isSignUp == true`:
   - Validación local: solo letras, números y guion bajo, mínimo 3 caracteres
   - Validación asíncrona: consultar `CheckUsernameAvailable` con debounce de ~500ms mientras el usuario escribe
   - Mostrar indicador de disponibilidad (✓ disponible / ✗ ya existe)
4. [ ] Actualizar `_submit()` para enviar `name` y `username` en el evento `SignUpWithEmailRequested`
5. [ ] Agregar strings de error/validación a los archivos de localización

---

## Phase 5: UI — Vista de Equipo (Asignación) [ ]
### Mostrar username en lugar de userId en los dropdowns y diálogos de asignación.

1. [ ] En `AddTeamTaskBottomSheet` — el dropdown de asignación muestra `e.key` (userId); cambiar para mostrar `e.value.username ?? e.key` (`lib/features/team_tasks/presentation/widgets/add_team_task_bottom_sheet.dart`)
2. [ ] En `_showAssignDialog` de `team_tasks_page.dart` — la lista muestra `e.key` y usa `e.key[0]` para el avatar; cambiar para mostrar `e.value.username` y usar `e.value.username[0]` para el avatar (`lib/features/team_tasks/presentation/pages/team_tasks_page.dart`)
3. [ ] En `TeamTaskCard` — si muestra el `assignedTo` (userId), actualizar para resolver y mostrar el username del miembro asignado (`lib/features/team_tasks/presentation/widgets/team_task_card.dart`)
4. [ ] En `MemberAvatarList` — actualizar el tooltip/inicial del avatar para usar username en lugar de userId (`lib/features/team_tasks/presentation/widgets/member_avatar_list.dart`)

---

## Phase 6: UI — Página de Configuración [ ]
### Mostrar nombre y username del usuario en la sección de perfil.

1. [ ] Actualizar `_ProfileSection` para recibir y mostrar el campo `username` del usuario (`lib/features/settings/presentation/pages/settings_page.dart`)
2. [ ] En `SettingsPage`, extraer `user.username` del estado `AuthAuthenticated` y pasarlo a `_ProfileSection`
3. [ ] Mostrar el username con formato `@username` como subtítulo secundario debajo del email

---

## Phase 7: Localización [ ]
### Agregar los nuevos strings de UI a los archivos de localización.

1. [ ] Agregar keys en inglés (`lib/l10n/app_localizations_en.dart`):
   - `nameLabel`, `nameEmptyError`
   - `usernameLabel`, `usernameEmptyError`, `usernameTooShortError`, `usernameInvalidError`
   - `usernameAvailable`, `usernameTaken`, `usernameChecking`
2. [ ] Agregar los mismos keys en español (`lib/l10n/app_localizations_es.dart`)
3. [ ] Declarar los nuevos getters en la clase abstracta `AppLocalizations` (`lib/l10n/app_localizations.dart`)

---

## Notas de Implementación

- **Unicidad del username**: Se valida consultando Firestore `users` donde `username == value`. Para evitar race conditions, la validación final se hace también en el servidor al momento de guardar (si el username ya fue tomado entre la validación y el submit, lanzar error).
- **Usuarios de Google Sign-In**: Al iniciar sesión con Google por primera vez, redirigir a una pantalla de completar perfil donde el usuario elige su `username`.
- **Retrocompatibilidad**: Usuarios ya registrados sin `username` en Firestore mostrarán el ID o "sin usuario" hasta que completen su perfil — considerar una pantalla de migración.
- **Firestore rules**: Asegurarse de que la colección `users` permita lectura pública del campo `username` para la validación, pero solo el dueño puede editar su documento.

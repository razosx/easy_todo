# Easy Todo — Plan de Implementación

App de gestión de tareas con Flutter, Firebase (Auth + Firestore + FCM), notificaciones locales, Clean Architecture y TDD.

## Resumen de Fases

| Fase | Descripción | Estado |
|------|-------------|--------|
| [Fase 1](phase_1_setup.md) | Setup & Arquitectura Foundation | ⏳ Pendiente |
| [Fase 2](phase_2_auth.md) | Autenticación (email/password + Google) | ⏳ Pendiente |
| [Fase 3](phase_3_tasks_domain_data.md) | Tareas: Domain & Data (Firestore) | ⏳ Pendiente |
| [Fase 4](phase_4_tasks_presentation.md) | Tareas: Presentación (Home Screen) | ⏳ Pendiente |
| [Fase 5](phase_5_local_notifications.md) | Notificaciones Locales | ⏳ Pendiente |
| [Fase 6](phase_6_push_notifications.md) | Notificaciones Push (FCM) | ⏳ Pendiente |
| [Fase 7](phase_7_settings.md) | Pantalla de Configuración | ⏳ Pendiente |
| [Fase 8](phase_8_integration.md) | Integración Final y Pulido | ⏳ Pendiente |
| [Fase 9](phase_9_team_tasks.md) | (Futura) Tareas de Equipo | 🔮 Futura |

## Reglas TDD

1. **RED** → escribir el test que falla
2. **GREEN** → mínimo código para pasar el test
3. **REFACTOR** → limpiar sin romper tests
4. Nunca omitir el paso RED
5. Mockear en domain; usar FakeFirestore en data
6. `flutter test --coverage` al final de cada fase

## Arquitectura

```
Clean Architecture
├── Domain   (entities, repositories interfaces, use cases)
├── Data     (models, data sources, repository implementations)
└── Presentation (BLoC, pages, widgets)
```

## Stack Técnico

- **State Management:** flutter_bloc + equatable
- **DI:** get_it + injectable
- **Error handling:** dartz (Either<Failure, T>)
- **Data classes:** freezed + json_serializable
- **Testing:** mocktail + bloc_test + fake_cloud_firestore

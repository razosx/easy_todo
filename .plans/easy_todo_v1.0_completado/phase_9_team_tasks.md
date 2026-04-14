# Fase 9 (Futura) — Tareas de Equipo

## Objetivo

Segunda fase del proyecto. Activar el Tab 2 del BottomNavigationBar con funcionalidad de tareas compartidas en equipo.

## Funcionalidades

- Crear un equipo o unirse a uno con código
- Ver tareas del equipo agrupadas por asignado/sin asignar
- Crear tareas y asignarlas a miembros del equipo
- Recibir notificación push cuando te asignan una tarea

## Estructura Firestore

```
teams/{teamId}/
├── name: String
├── createdBy: String (userId)
├── members: Map<userId, { role: 'admin'|'member', joinedAt: Timestamp }>
└── tasks/{taskId}/
      title: String
      description: String
      assignedTo: String? (userId)
      createdBy: String (userId)
      dueDate: Timestamp?
      isCompleted: bool
      createdAt: Timestamp
      priority: String

users/{userId}/
└── teams: List<String> (teamIds)
```

## Archivos a crear (Fase 9)

```
lib/features/team_tasks/
├── domain/
│   ├── entities/
│   │   ├── team_entity.dart
│   │   └── team_task_entity.dart
│   ├── repositories/
│   │   ├── team_repository.dart
│   │   └── team_task_repository.dart
│   └── usecases/
│       ├── create_team.dart
│       ├── join_team.dart
│       ├── get_team_tasks.dart
│       ├── create_team_task.dart
│       ├── assign_task_to_member.dart
│       └── complete_team_task.dart
├── data/
│   ├── datasources/
│   │   ├── team_remote_data_source.dart
│   │   └── team_task_remote_data_source.dart
│   ├── models/
│   │   ├── team_model.dart
│   │   └── team_task_model.dart
│   └── repositories/
│       ├── team_repository_impl.dart
│       └── team_task_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── team_tasks_bloc.dart
    │   └── team_bloc.dart
    ├── pages/
    │   ├── team_tasks_page.dart
    │   ├── create_team_page.dart
    │   └── join_team_page.dart
    └── widgets/
        ├── team_task_card.dart
        └── member_avatar_list.dart
```

## Notificaciones Push para asignaciones

Al asignar una tarea a un miembro:
1. Obtener token FCM del usuario desde `users/{userId}/fcmTokens`
2. Enviar notificación desde Firebase Cloud Functions o desde el cliente con Admin SDK
3. Payload: `{ taskId, teamId, title, assignedBy }`

## Reglas de seguridad Firestore (Fase 9)

```javascript
// Tareas de equipo: solo miembros del equipo pueden leer/escribir
match /teams/{teamId}/tasks/{taskId} {
  allow read, write: if request.auth.uid in get(/databases/$(database)/documents/teams/$(teamId)).data.members;
}
```

## Notas

- El Tab 2 mostrará un placeholder ("Próximamente") hasta que esta fase esté completa
- Se puede activar con un feature flag en `shared_preferences`
- La arquitectura de la Fase 1-8 ya está preparada para añadir este feature sin cambios estructurales

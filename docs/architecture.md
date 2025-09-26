# Productivity App Architecture (Flutter, FOSS on GitHub)

This document outlines a refined architecture for your open-source productivity app built with Flutter. It adopts **Clean Architecture** for separation of concerns, ensuring maintainability, testability, scalability, and ease of collaboration. Refinements include:
- Enhanced modularity with feature packages for better OSS contributions.
- Deeper integration of state management with Riverpod, including auto-dispose and family providers.
- Added focus on offline-first design, accessibility, and internationalization.
- Explicit handling of async operations, error states, and performance metrics.
- Updated for Flutter 3.24+ (as of 2025), leveraging Impeller for smoother rendering and Dart 3.5+ features like enhanced records and patterns.
- CI/CD refinements for GitHub Actions, including code coverage reports.
- Security and privacy best practices, e.g., data encryption and minimal permissions.

The app supports features: task capture, SMART goals, Eisenhower Matrix, habit tracking, time blocking, Pomodoro, and periodic reviews.

## High-Level Architecture Overview

- **Layers** (Concentric, from inner to outer):
  - **Domain (Core)**: Pure business logic, entities, and use cases. Framework-agnostic (pure Dart).
  - **Data**: Concrete implementations for storage and external APIs.
  - **Presentation**: UI, state management, and user interactions.
  - **Infrastructure**: Cross-cutting utilities like DI, logging, and notifications.

- **Key Principles**:
  - **Dependency Rule**: Outer layers depend on inner ones (via abstractions).
  - **Offline-First**: All features work without internet; sync optional for future cloud integration.
  - **Modularity**: Features as independent modules/packages for easy extension.
  - **Performance**: 60fps target; use const, memoization, and isolates.
  - **Testability**: >80% coverage; TDD encouraged.
  - **Collaboration**: Clear docs, linters, and GitHub workflows.

## Folder Structure

Use a monorepo with feature-specific packages under `packages/` for reusability and independent testing. This allows contributors to work on isolated features.

```
productivity_app/
├── lib/                          # Main app entry
│   ├── main.dart                 # App bootstrap (DI setup, theme, router)
│   ├── app.dart                  # Root widget (MaterialApp with router)
│   └── config/                   # Env configs (dev/prod flavors)
├── packages/                     # Modular packages
│   ├── core/                     # Domain layer (pubspec.yaml for package)
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── entities/     # e.g., Task.dart, Habit.dart (immutable records)
│   │   │   │   ├── usecases/     # e.g., CreateSmartGoalUseCase.dart
│   │   │   │   └── repositories/ # Interfaces: TaskRepository.dart
│   │   │   └── exports.dart      # Barrel file
│   │   └── test/                 # Unit tests
│   ├── data/                     # Data layer
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── datasources/  # Local: HiveDataSource.dart; Remote: (optional) FirebaseDataSource.dart
│   │   │   │   ├── models/       # Serializable DTOs: TaskModel.dart
│   │   │   │   └── repositories/ # Impl: TaskRepositoryImpl.dart
│   │   │   └── exports.dart
│   │   └── test/
│   ├── presentation/             # Presentation layer
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── features/     # Sub-packages for each feature
│   │   │   │   │   ├── task_capture/    # Widgets, providers: TaskCaptureScreen.dart
│   │   │   │   │   ├── smart_goals/     # Similar for each
│   │   │   │   │   ├── eisenhower/
│   │   │   │   │   ├── habit_tracking/
│   │   │   │   │   ├── time_blocking/
│   │   │   │   │   ├── pomodoro/
│   │   │   │   │   └── reviews/
│   │   │   │   ├── common/       # Shared: widgets, themes, utils
│   │   │   │   ├── navigation/   # AppRouter.dart (GoRouter)
│   │   │   │   └── providers/    # App-wide: ThemeProvider.dart
│   │   │   └── exports.dart
│   │   └── test/                 # Widget/integration tests
│   ├── infrastructure/           # Cross-cutting
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── di/           # injector.dart (GetIt + Injectable)
│   │   │   │   ├── logging/      # Logger.dart (with Sentry integration)
│   │   │   │   ├── notifications/# LocalNotifications.dart
│   │   │   │   └── utils/        # Extensions, helpers
│   │   │   └── exports.dart
│   │   └── test/
├── test/                         # App-level integration tests
├── analysis_options.yaml         # Strict linting (very_good_analysis)
├── pubspec.yaml                  # Top-level deps; depend on packages/
├── README.md                     # Overview, setup, architecture diagram (Mermaid)
├── CONTRIBUTING.md               # Guidelines for OSS
└── .github/                      # Workflows: CI (lint, test, coverage), PR templates
```

## Key Architectural Components

### 1. Domain Layer (Core)
- **Entities**: Immutable Dart records (e.g., `record Task(String id, String description, EisenhowerQuadrant quadrant);`). Include validation logic.
- **Use Cases**: Pure functions/classes for business rules (e.g., `class PrioritizeTaskUseCase { Either<Failure, Task> execute(Task task, EisenhowerInput input); }`). Use `fpdart` for functional error handling (Either<Failure, Result>).
- **Repositories**: Abstract interfaces for data ops (e.g., `Stream<List<Habit>> getHabitsStream();`).
- **Refinements**: Add domain events (e.g., TaskCompletedEvent) for pub-sub if needed. Keep 100% testable with mocks.

### 2. Data Layer
- **Data Sources**: 
  - Local: Hive for key-value storage (fast, encrypted boxes for tasks/habits). Use adapters for custom serialization.
  - Remote: Optional (e.g., Supabase for sync); fallback to local on offline.
- **Repositories Impl**: Inject sources; handle CRUD with caching. Use `dartz` for async results.
- **Refinements**: Migrations via Hive's schema versioning. Secure storage for sensitive data (flutter_secure_storage). Streams for real-time UI updates.

### 3. Presentation Layer
- **State Management**: Riverpod 2.5+ (preferred over Bloc for simplicity). Use `NotifierProvider` for mutable state (e.g., PomodoroTimerNotifier), `StreamProvider` for data streams. Auto-dispose for memory efficiency; family providers for parameterized state (e.g., `taskProviderFamily(id)`).
- **UI**: 
  - Widgets: Compositional, with keys for performance. Use `SliverList` for dashboards; `DraggableScrollableSheet` for modals (e.g., reviews).
  - Features: Each in its sub-package with isolated providers/routes. E.g., Eisenhower feature: drag-and-drop grid with `DragTarget`.
- **Navigation**: GoRouter 2.0+ with shell routes for tabs (dashboard, settings). Deep linking for sharing tasks.
- **Refinements**: Accessibility (Semantics, TalkBack); i18n (intl package); adaptive layouts (Responsive Framework for tablet/web). Error widgets for loading/failure states.

### 4. Infrastructure Layer
- **DI**: GetIt + Injectable (auto-generate registrations). Lazy singles for heavy objects.
- **Logging & Monitoring**: Logger package; integrate Sentry for crashes. Analytics optional (Mixpanel FOSS alternative).
- **Notifications**: flutter_local_notifications for Pomodoro/reminders; integrate with device calendars (device_calendar plugin).
- **Async/Performance**: Use isolates for heavy tasks (e.g., streak calculations). Zone.guarded for global error catching.
- **Refinements**: App flavors (flutter_flavorizr); hot reload support. Permissions: Minimal (storage, notifications); request on-demand.

## Best Practices

### Code Quality
- **Linting/Formatting**: very_good_analysis; auto-format on save. Pre-commit hooks (lefthook).
- **Style**: Effective Dart; avoid globals, prefer const/final.

### Testing
- **Levels**: Unit (domain/data), Widget (UI), Integration (flows like task-to-Pomodoro).
- **Tools**: flutter_test, mockito, golden_toolkit for snapshots.
- **Coverage**: Enforce >80% via GitHub Actions; badges in README.

### Version Control & Collaboration
- **Git**: Conventional commits; semantic-release for versioning.
- **OSS**: Code of Conduct (Contributor Covenant); issue/PR templates. Roadmap in README.
- **CI/CD**: GitHub Actions: Lint/test on PR; build/release on tags. Coverage reports via Codecov.

### Deployment & Maintenance
- **Builds**: Android/iOS flavors; web/desktop support via Flutter's multi-platform.
- **Monitoring**: Beta testing via Firebase App Distribution.
- **Updates**: Over-the-air via CodePush if needed.
- **Security**: Encrypt Hive boxes; no hard-coded secrets. Privacy policy in repo.


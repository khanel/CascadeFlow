# CascadeFlow Architecture Guide

CascadeFlow adopts a **feature-based Clean Architecture** that keeps business logic, data, and UI concerns grouped by feature while sharing only the lightest possible primitives. The structure is optimised for an open-source monorepo where contributors can focus on a single feature slice without touching the entire codebase.

## Guiding Principles
- **Vertical slices first**: Every feature owns its domain, data, and presentation layers inside a dedicated package under `features/`.
- **Tiny, stable core**: Only universal value objects, failures, and shared events live in `core/`.
- **Riverpod everywhere**: Dependency injection and state management flow through Riverpod providers—no GetIt; rely on `riverpod_annotation`/`riverpod_generator` for typed provider codegen.
- **Infrastructure as a service hub**: Cross-cutting helpers (Hive CE init, secure storage, notifications, logging) sit in `infrastructure/` and are consumed through providers.
- **Offline-first, privacy-friendly**: Local storage via encrypted Hive CE boxes per feature; remote sync is an opt-in future concern.
- **Test-driven delivery**: Practice TDD—write the failing test first, implement the minimal code to pass, then refactor with coverage tracked through Melos.

## Feature Pillars (Current MVP Order)
These slices define the initial user journey and map directly to packages under `features/`.
- **Ingest** – Frictionless capture (widgets, quick-add, voice/text) funnels raw ideas into an inbox so nothing slips away mid-flow.
- **Goals** – SMART-aligned goal space that translates ambitions into measurable, actionable guidance for downstream features.
- **Prioritize** – Decision tooling (Eisenhower matrix, scoring, sorting) that bubbles up what matters most from the backlog.
- **Tasks** – Core task management CRUD with metadata (due dates, tags, subtasks) that keeps execution grounded.
- **Habits** – Recurring routines with streak tracking, cadence rules, and reminders that turn goals into behaviour change.
- **Schedule** – Calendar/time-blocking surfaces that place tasks and habits on the timeline, handle conflicts, and keep plans realistic.
- **Focus** – Execution helpers such as Pomodoro timers and distraction-free flow so users stay on task during scheduled blocks.
- **Review** – Weekly/custom retrospectives summarising wins, misses, and lessons, prompting plan adjustments and carry-over decisions.
- **Metrics** – Dashboards and analytics (trends, distributions, streaks) that surface behavioural patterns beyond raw lists.
- **Insights** – Smart nudges and recommendations (e.g., repeatedly postponed tasks) that reduce cognitive load and highlight blind spots.
- **Integrations** – External interfaces and configuration (calendar sync, export/import, feature toggles, notifications, theming) so CascadeFlow fits personal ecosystems.

## Package Topology
The repository is a Melos workspace. Each directory below becomes a package with its own `pubspec.yaml` and tests.

```
/                                 # Repo root (Melos workspace)
├── app/                          # Flutter runner; bootstraps providers, theme, router
├── core/                         # Shared primitives (Failure, Result, value objects, events)
├── infrastructure/               # Cross-feature services (Hive CE init, notifications, secure storage, logging)
└── features/
    ├── ingest/
    ├── goals/
    ├── prioritize/
    ├── tasks/
    ├── habits/
    ├── schedule/
    ├── focus/
    ├── review/
    ├── metrics/
    ├── insights/
    └── integrations/
```

Each feature package repeats the same internal structure:
- `domain/` – Entities, value objects, and use cases unique to the feature (e.g., capture items, goal definitions, prioritisation rules, focus sessions).
- `data/` – Data sources, DTOs/adapters, repository implementations.
- `presentation/` – Riverpod providers, notifiers, UI widgets, and navigation hooks.

Packages depend only “downward”:
- A feature can depend on `core` plus `infrastructure` when it needs shared services.
- `app` depends on every feature package, plus `core` and `infrastructure`.
- Features never depend on each other directly; shared behaviour is expressed via events or persisted state.

## Workspace Tooling (Melos)
Melos manages package linking, scripts, and testing.
- Root `melos.yaml` enumerates `app`, `core`, `infrastructure`, and every folder in `features/*` as packages.
- Common scripts:
  - `melos bootstrap` – install dependencies for all packages.
  - `melos run analyze` – run static analysis across the workspace.
  - `melos test` – execute all tests (unit, widget, integration).

## Core Package (`core/`)
Purpose: hold immutable building blocks used across multiple features.
- Failures and Result/Either types.
- Value objects shared by more than one slice (identifiers, timestamps, lightweight enums).
- Cross-feature event contracts (e.g., `CaptureItemFiled`, `FocusSessionCompleted`) that allow slices to communicate without tight coupling.
- No repositories, use cases, or heavy business rules—those stay inside feature packages.

## Infrastructure Package (`infrastructure/`)
Purpose: offer reusable services via Riverpod providers.
- Hive CE initialisation utilities plus encrypted box helpers (using `flutter_secure_storage` for AES keys).
- Logging adapters (e.g., `logger`) and error reporting hooks.
- Notification scheduler built on `flutter_local_notifications` for focus/break timers, habit nudges, and schedule reminders.
- Platform utilities such as configuration loaders or secure storage wrappers.
- DI surface is still Riverpod: expose providers that features can `ref.watch` or `ref.read`.

## Feature Packages (`features/*`)
Each feature encapsulates its stack so contributors can evolve it independently.

### Domain layer
- Entities model the feature’s concepts (e.g., `CaptureItem`, `Goal`, `PriorityRule`, `FocusSession`).
- Value objects enforce invariants (e.g., non-empty descriptions, focus durations).
- Use cases coordinate domain rules and return `Result`/`Either` values.
- Repository interfaces describe the data contracts but remain local to the feature.

### Data layer
- DTOs and Hive CE adapters translate between domain entities and persisted models.
- Local data sources wrap Hive CE boxes (encrypted per feature) and expose streams + CRUD operations.
- Repository implementations orchestrate data sources and map into domain models.

### Presentation layer
- Riverpod providers wire dependencies (e.g., repository provider, use-case providers).
- `Notifier`/`AsyncNotifier` classes encapsulate state changes.
- Widgets/screens compose the UI for the feature; navigation segments register with the app router.
- Tests use Riverpod overrides to validate behaviour in isolation.
- Generated provider files live alongside the source (`part 'foo.g.dart'`) and are maintained via `dart run build_runner watch`.

## App Package (`app/`)
Bootstraps the Flutter application:
- Entry point configures Flutter bindings, initialises Hive CE via `infrastructure`, and loads secure keys.
- Wraps the tree in a `ProviderScope` with overrides for feature repositories/services as needed.
- Hosts theming, localisation, and the GoRouter setup (including `StatefulShellRoute` for tabbed navigation).

## Cross-Slice Communication
Two light-touch options keep slices decoupled:
1. **Event stream**: `core` defines an event contract; `app` composes a Riverpod provider that exposes a broadcast stream or bus. Features emit domain events (e.g., `CaptureItemFiled`, `FocusSessionCompleted`) which other features subscribe to.
2. **Persisted audit**: A slice writes summary data (e.g., completed tasks, habit streak changes) that other slices read as needed.

Choose the simplest path per interaction; avoid tight compile-time dependencies between feature packages.

## Dependency Management
- Add dependencies to individual packages only when required; record them in `docs/development/dependency-log.md`.
- Prefer `dev_dependencies` for testing/tooling inside each package.
- Keep `core` dependency-free beyond small, pure Dart packages.

## Testing Strategy
- We work in TDD cycles: red (write a failing test), green (make it pass), refactor (improve design while keeping tests green).
- **Domain**: Pure unit tests of entities and use cases inside each feature package.
- **Data**: Tests using temp Hive CE boxes (with encryption) to validate repositories and data sources.
- **Presentation**: Widget tests and notifier tests leveraging Riverpod overrides.
- Melos aggregates coverage so we can track quality trends.

## Contributor Notes
- New contributions should add or modify code inside a feature slice. Only touch `core` when a type is truly shared.
- Follow the templates in `docs/project/progress.md` and `docs/project/roadmap.md` for consistent slice scaffolding.
- Document feature-specific decisions in the feature package README (optional but encouraged).

This architecture keeps CascadeFlow modular, approachable, and resilient as new collaborators join and features evolve.

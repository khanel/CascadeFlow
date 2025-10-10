# CascadeFlow Development Roadmap

This roadmap sequences the work required to deliver CascadeFlow’s MVP while transitioning the project to a feature-based Clean Architecture. Each milestone focuses on an observable increment (code, tests, or documentation). Run Melos commands (`melos bootstrap`, `melos run analyze`, `melos test`) at every milestone checkpoint.

## Milestone 1 – Workspace Restructure & Tooling
Goal: Establish the vertical-slice repository layout and supporting tooling.
- Create top-level packages: `app/`, `core/`, `infrastructure/`, and `features/<pillar>/` directories (`ingest`, `goals`, `prioritize`, `tasks`, `habits`, `schedule`, `focus`, `review`, `metrics`, `insights`, `integrations`).
- Add `melos.yaml` enumerating all packages and shared scripts for analyse/test flows.
- Update root and package `pubspec.yaml` files with path dependencies that match the new structure.
- Migrate existing code into the new packages (keep `core` intentionally minimal).
- Refresh documentation (README, contributor notes) to outline the feature-first workflow and Melos usage.

## Milestone 2 – Core Primitives
Goal: Populate `core/` with universal types while keeping it intentionally tiny.
- Introduce `Failure`, `Result/Either`, and shared value objects (IDs, timestamps, etc.).
- Define cross-feature event contracts (e.g., `CaptureItemFiled`, `FocusSessionCompleted`).
- Add lightweight utilities reused by multiple slices while avoiding business rules in `core`.
- Cover invariants with unit tests.

## Milestone 3 – Infrastructure Services
Goal: Centralise cross-cutting concerns in `infrastructure/` and expose them through Riverpod providers.
- Implement Hive initialisation utilities, including encrypted box helpers that fetch AES keys via `flutter_secure_storage`.
- Add logging adapters and global error handling hooks.
- Create notification facades powered by `flutter_local_notifications` for focus timers, schedule reminders, and habit nudges.
- Provide configuration helpers and secure storage wrappers.
- Document consumption patterns for feature slices and add smoke tests where practical.

## Milestone 4 – App Composition & Navigation
Goal: Compose the application shell before wiring feature slices.
- Configure GoRouter with a `StatefulShellRoute` whose branches mirror the main pillars (e.g., Capture, Plan, Execute, Review, Insights, Settings).
- Ensure each branch preserves its navigation stack while switching tabs.
- Bootstrap ProviderScope, theming, Hive initialisation, secure storage, and notifications in `app/main.dart`.
- Provide placeholder routes/screens for each branch to unblock feature slices.
- **Integration Tests**: Add integration tests verifying tab navigation flows (stack preservation/reset), bootstrap initialization (notification facade lifecycle, adapter registry diagnostics), and cross-branch navigation behavior.

## Milestone 5 – Feature Slice: Ingest
- **Domain**: Define `CaptureItem` entity, validation rules, and use cases (`CaptureQuickEntry`, `ArchiveCaptureItem`).
- **Data**: Model DTO/adapter for capture items, open encrypted inbox box, implement local data source and repository with tests.
- **Presentation**: Riverpod providers for capture workflows, quick-add UI (text/voice), and inbox list with widget tests.
- **Post-MVP Enhancements**: Hook archive/delete interactions into the UI, replace placeholder detail routes with real capture views, add voice capture onboarding, surface refresh affordances, tighten error messaging, wire downstream consumers of capture events, and expand integration/widget tests covering multi-step flows.

## Milestone 6 – Feature Slice: Goals
- **Domain**: Goal entity with SMART metadata, sub-goal relationships, and use cases (`CreateGoal`, `UpdateGoalProgress`).
- **Data**: Hive storage for goals, repository implementation, and tests covering CRUD + progress tracking.
- **Presentation**: Goal editors, progress views, and Riverpod notifiers; integrate with capture items for goal linking.

## Milestone 7 – Feature Slice: Prioritize
- **Domain**: Priority rule/value objects, use cases (`RankBacklog`, `AssignQuadrant`).
- **Data**: Persist priority states and historical decisions; enable streams for UI updates.
- **Presentation**: Eisenhower-style board, scoring view, and provider logic for surfacing top recommendations.

## Milestone 8 – Feature Slice: Tasks
- **Domain**: Task entity, status transitions, use cases (`AddTask`, `CompleteTask`, `RescheduleTask`).
- **Data**: Task DTOs/adapters, repository implementation layering on capture + prioritisation data.
- **Presentation**: Task list/detail UIs, Riverpod notifiers, and tests covering lifecycle operations.

## Milestone 9 – Feature Slice: Habits
- **Domain**: Habit entity, streak logic, cadence rules, and use cases (`LogHabit`, `AdjustCadence`).
- **Data**: Encrypted habit box, repository implementation with streak calculations.
- **Presentation**: Habit trackers, streak visualisations, notification hooks, and widget tests.

## Milestone 10 – Feature Slice: Schedule
- **Domain**: Schedule block entity, conflict resolution rules, and use cases (`PlanBlock`, `ShiftBlock`).
- **Data**: Persistence for blocks and availability windows; repository producing calendar feeds.
- **Presentation**: Calendar/time-line UI, drag/drop planning tools, and provider logic syncing with tasks/habits.

## Milestone 11 – Feature Slice: Focus
- **Domain**: Focus session entity, timer rules, and use cases (`StartFocusSession`, `PauseFocusSession`).
- **Data**: Session history storage, repository linking to tasks/blocks.
- **Presentation**: Pomodoro-style timers, distraction-minimised UI, auto-break handling, and notification integration.

## Milestone 12 – Feature Slice: Review
- **Domain**: Review session entity, reflection prompts, and use cases (`GenerateWeeklyReview`, `CarryOverItems`).
- **Data**: Persist review notes and summary metrics; repository exposing insights for dashboards.
- **Presentation**: Review wizard, summary cards, and provider logic that aggregates recent activity.

## Milestone 13 – Feature Slice: Metrics
- **Domain**: Metric definitions and aggregation rules.
- **Data**: Build analytics pipelines (local aggregations) and caches for charting.
- **Presentation**: Dashboard widgets, charts, filters, and tests ensuring calculations render correctly.

## Milestone 14 – Feature Slice: Insights
- **Domain**: Insight rules and scoring, use cases (`GenerateInsightRecommendations`).
- **Data**: Persist signals/flags, maintain history for comparisons.
- **Presentation**: Insight feed, notification hooks, and dismiss/act flows with provider support.

## Milestone 15 – Feature Slice: Integrations
- **Domain**: Connection entities (calendars, exports), use cases (`SyncCalendar`, `ExportData`).
- **Data**: Securely store tokens/config, map external data into internal formats.
- **Presentation**: Settings panels for feature toggles, sync status, and import/export workflows.

## Milestone 16 – Notifications & Event Fabric
Goal: Ensure cross-slice communication and reminders are cohesive.
- Wire infrastructure notification facades into Habits, Schedule, Focus, and Review slices.
- Implement the shared event stream provider and ensure each slice emits/consumes relevant events.
- Add tests for notification scheduling, event emission, and downstream reactions.

## Milestone 17 – Testing & Quality Gates
Goal: Lock in confidence before broadening contributions.
- Configure Melos test orchestration and collect coverage reports.
- Add unit tests for domain logic, data repositories (with encrypted Hive boxes), and Riverpod notifiers/widgets across completed slices.
- Prepare CI scaffolding (GitHub Actions workflow outline) even if automation isn’t fully enabled yet.

## Milestone 18 – Contributor Experience & Documentation
Goal: Provide a frictionless on-ramp for collaborators.
- Finalise `CONTRIBUTING.md` with feature-slice workflow, Melos commands, coding standards, and review expectations.
- Update the main README with architecture diagrams, workflow summaries, and links to key docs.
- Provide templates/checklists that new slices can copy.
- Mark superseded layered-architecture documentation as historical context.

## Beyond the MVP
After the eleven pillars are in place, iterate on advanced analytics, optional cloud sync, collaboration features, and community-driven extensions. Maintain the feature-slice rhythm: domain → data → presentation → tests, always orchestrated through Riverpod and Melos.

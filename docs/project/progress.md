# CascadeFlow Roadmap Progress Tracker

Use this checklist to track progress against the roadmap. Tick off tasks as they are completed.

Dependency policy: add packages only as needed, step-by-step with development. See `docs/development/dependency-policy.md` and record changes in `docs/development/dependency-log.md`.

Development cadence: every task runs through TDD—write the failing test, add the minimal implementation, then refactor with the suite green.

## Status Snapshot (2025-09-30)
- Current focus: kick off CaptureItem domain modelling and notification facade design now that the feature-based restructure is in place.
- Next actions:
  - Execute the bootstrap initialisation checklist under Milestone 4.
  - Add placeholder routes/screens for each navigation branch to unblock feature integration work.
  - Flesh out presentation scaffolds so slice packages can begin wiring real UI flows.
- Recently completed: repo init, Flutter skeleton, README, LICENSE, .gitignore, strict linting, dependency policy/log, packages directory scaffolds, Melos workspace config with path dependencies, core primitives and shared event contracts, Ingest slice planning brief, CONTRIBUTING workflow guide, initial infrastructure stubs (PrintLogger, in-memory Hive + secure storage), logging helper with global error hook, provider registry documentation, `Result.guard`/`guardAsync` helper utilities. Updated workspace test script to skip empty packages, seeded placeholder test scaffolds across unwired packages, established `CaptureItem` domain entity with validation/context metadata. Ensured tab re-selection resets each branch to its root while preserving cross-branch navigation stacks using go_router's `StatefulNavigationShell`.

## Milestone 1 – Workspace Restructure & Tooling
- [x] Adopt feature-based directory layout (`/app`, `/core`, `/infrastructure`, `/features/<pillar>`).
- [x] Add root `melos.yaml` covering `app`, `core`, `infrastructure`, and each feature package.
- [x] Update app/feature `pubspec.yaml` files to use path dependencies and Melos scripts (`melos bootstrap`, `melos run analyze`, `melos test`).
- [x] Migrate existing code into the new packages without bloating `core`.
- [x] Document Melos usage in contributor notes and ensure CI scripts reference it.

## Milestone 2 – Core Primitives & Event Contracts
- [x] Implement `Failure`, `Result/Either`, IDs/time value objects inside `core/`.
- [x] Define shared events (e.g., `CaptureItemFiled`, `FocusSessionCompleted`) consumed across slices.
- [x] Add lightweight helpers reused by multiple slices while keeping business logic out of `core`.
- [x] Cover invariants with unit tests.

## Milestone 3 – Infrastructure Services
- [x] Implement Hive initialisation + encryption helpers that `app` can call at startup.
- [x] Add secure storage wrapper (e.g., `flutter_secure_storage`) for Hive keys.
- [x] Provide logging utilities and global error handling hooks.
- [x] Expose notification facades for focus timers, schedule reminders, and habit nudges.
- [x] Document Riverpod providers that slices should consume.

## Milestone 4 – App Composition & Navigation
- [x] Configure `StatefulShellRoute` branches aligned with pillars (Capture, Plan, Execute, Review, Insights, Settings).
- [x] Ensure each branch preserves its navigation stack when switching tabs.
- [ ] Complete bootstrap initialisation:
  - [ ] Apply the shared light/dark themes and adaptive layout breakpoints to the root `MaterialApp`.
  - [ ] Wrap the entry widget with `ProviderScope` and register global overrides/providers.
  - [ ] Introduce an async bootstrap runner that requests the secure storage key and configures Hive before `runApp`.
  - [ ] Register required Hive adapters and open base boxes used by the app shell.
  - [ ] Initialise the notification facade (permissions, channels, background handlers) prior to UI launch.
- [ ] Add placeholder routes/screens for each branch to unblock feature integration.

## Milestone 5 – Feature: Ingest
### Domain (`features/ingest/domain`)
- [x] Define `CaptureItem` entity with validation and context metadata.
- [ ] Implement use cases: `CaptureQuickEntry`, `ArchiveCaptureItem`.

### Data (`features/ingest/data`)
- [ ] Register Hive adapters for capture items and open encrypted inbox box.
- [ ] Build `CaptureLocalDataSource` and repository implementation with tests using temp boxes.

### Presentation (`features/ingest/presentation`)
- [ ] Add Riverpod providers for capture workflows and inbox state.
- [ ] Ship quick-add UI (text/voice) and inbox list with widget tests.

## Milestone 6 – Feature: Goals
### Domain (`features/goals/domain`)
- [ ] Define `Goal` entity with SMART fields and linkage to capture items/tasks.
- [ ] Implement use cases: `CreateGoal`, `UpdateGoalProgress`.

### Data (`features/goals/data`)
- [ ] Create Hive models/adapters for goals and progress checkpoints.
- [ ] Build local data source + repository with tests covering progress calculations.

### Presentation (`features/goals/presentation`)
- [ ] Provide Riverpod notifiers for goal lifecycle and progress.
- [ ] Implement goal editor and progress views with widget tests.

## Milestone 7 – Feature: Prioritize
### Domain (`features/prioritize/domain`)
- [ ] Model priority rules/value objects (quadrants, scores).
- [ ] Implement use cases: `RankBacklog`, `AssignQuadrant`.

### Data (`features/prioritize/data`)
- [ ] Persist priority states and decisions; expose streams for UI updates.
- [ ] Add repository tests verifying sorting/scoring behaviour.

### Presentation (`features/prioritize/presentation`)
- [ ] Build Eisenhower board / ranking UI components.
- [ ] Implement providers that surface top recommendations.

## Milestone 8 – Feature: Tasks
### Domain (`features/tasks/domain`)
- [ ] Define `Task` entity with status transitions and schedule hooks.
- [ ] Implement use cases: `AddTask`, `CompleteTask`, `RescheduleTask`.

### Data (`features/tasks/data`)
- [ ] Create task DTOs/adapters and open encrypted task box.
- [ ] Build local data source + repository with tests covering lifecycle operations.

### Presentation (`features/tasks/presentation`)
- [ ] Provide Riverpod notifiers for task lists and detail state.
- [ ] Implement task list/detail UI with widget tests.

## Milestone 9 – Feature: Habits
### Domain (`features/habits/domain`)
- [ ] Define `Habit` entity, streak logic, and cadence rules.
- [ ] Implement use cases: `LogHabit`, `AdjustCadence`.

### Data (`features/habits/data`)
- [ ] Persist habits/streaks with encrypted storage; add repository tests for streak updates.

### Presentation (`features/habits/presentation`)
- [ ] Create habit tracker UI and Riverpod providers for streak state.
- [ ] Integrate notification hooks for reminders.

## Milestone 10 – Feature: Schedule
### Domain (`features/schedule/domain`)
- [ ] Model schedule block entity and conflict resolution rules.
- [ ] Implement use cases: `PlanBlock`, `ShiftBlock`.

### Data (`features/schedule/data`)
- [ ] Store time blocks and availability windows; add repository tests for conflict handling.

### Presentation (`features/schedule/presentation`)
- [ ] Build calendar/time-line UI for drag-and-drop planning.
- [ ] Sync providers with tasks/habits and add widget tests.

## Milestone 11 – Feature: Focus
### Domain (`features/focus/domain`)
- [ ] Define `FocusSession` entity with timer rules and outcomes.
- [ ] Implement use cases: `StartFocusSession`, `PauseFocusSession`, `CompleteFocusSession`.

### Data (`features/focus/data`)
- [ ] Persist focus session history linked to tasks/blocks; write repository tests.

### Presentation (`features/focus/presentation`)
- [ ] Deliver Pomodoro-style UI with distraction controls and Riverpod providers.
- [ ] Integrate notification triggers for start/break/end events.

## Milestone 12 – Feature: Review
### Domain (`features/review/domain`)
- [ ] Create `ReviewSession` entity, prompts, and aggregation rules.
- [ ] Implement use cases: `GenerateWeeklyReview`, `CarryOverItems`.

### Data (`features/review/data`)
- [ ] Persist review notes and summaries; ensure repository tests cover aggregation.

### Presentation (`features/review/presentation`)
- [ ] Build review wizard/summary UI with provider-backed state.
- [ ] Add widget tests covering reflection flows.

## Milestone 13 – Feature: Metrics
### Domain (`features/metrics/domain`)
- [ ] Define metric descriptors and aggregation logic.
- [ ] Implement use cases: `ComputeMetricSeries`, `CompareMetricWindows`.

### Data (`features/metrics/data`)
- [ ] Create local analytics caches and repositories for chart data.

### Presentation (`features/metrics/presentation`)
- [ ] Implement dashboard widgets, charts, and filter providers with tests.

## Milestone 14 – Feature: Insights
### Domain (`features/insights/domain`)
- [ ] Define insight rules/scoring and use cases: `GenerateInsightRecommendations`.

### Data (`features/insights/data`)
- [ ] Persist insight signals, statuses, and history; add repository tests.

### Presentation (`features/insights/presentation`)
- [ ] Build insight feed UI and provider logic for dismiss/act flows.
- [ ] Connect to notification/event system for proactive nudges.

## Milestone 15 – Feature: Integrations
### Domain (`features/integrations/domain`)
- [ ] Model external connection entities and use cases: `SyncCalendar`, `ExportData`, `ToggleFeature`.

### Data (`features/integrations/data`)
- [ ] Securely store tokens/preferences and map external payloads to internal models.

### Presentation (`features/integrations/presentation`)
- [ ] Implement settings panels for sync state, feature toggles, and import/export workflows with tests.

## Milestone 16 – Notifications & Event Fabric
- [ ] Wire notification facades into Habits, Schedule, Focus, Review, and Insights slices.
- [ ] Publish/consume shared events across slices using Riverpod providers.
- [ ] Add tests verifying scheduling, emissions, and downstream reactions.

## Milestone 17 – Testing & Quality Gates
- [ ] Configure `melos test` to orchestrate package-level tests and collect coverage.
- [ ] Ensure domain, data, and presentation tests exist for completed slices.
- [ ] Draft GitHub Actions workflow for linting, testing, and coverage reporting.

## Milestone 18 – Contributor Experience & Documentation
- [ ] Finalise `CONTRIBUTING.md` with feature-slice workflow, Melos commands, and review expectations.
- [ ] Update README/architecture diagrams with the eleven pillars and workspace guidance.
- [ ] Provide templates/checklists for adding new slices.
- [ ] Annotate historical layered documentation as legacy context.

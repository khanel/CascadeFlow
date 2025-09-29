# CascadeFlow Roadmap Progress Tracker

Use this checklist to track progress against the roadmap. Tick off tasks as they are completed.

Dependency policy: add packages only as needed, step-by-step with development. See `docs/development/dependency-policy.md` and record changes in `docs/development/dependency-log.md`.

Development cadence: every task runs through TDD—write the failing test, add the minimal implementation, then refactor with the suite green.

## Status Snapshot (2025-09-30)
- Current focus: convert the repo to feature-based Clean Architecture, wire the Melos workspace, and scope the Ingest slice.
- Next actions:
  - Scaffold `melos.yaml` and align all `pubspec.yaml` files with path dependencies.
  - Move universal primitives into `core/` and define initial event contracts.
  - Outline Ingest domain/data/presentation tasks ahead of implementation.
- Recently completed: repo init, Flutter skeleton, README, LICENSE, .gitignore, strict linting, dependency policy/log, packages directory scaffolds.

## Milestone 1 – Workspace Restructure & Tooling
- [ ] Adopt feature-based directory layout (`/app`, `/core`, `/infrastructure`, `/features/<pillar>`).
- [ ] Add root `melos.yaml` covering `app`, `core`, `infrastructure`, and each feature package.
- [ ] Update app/feature `pubspec.yaml` files to use path dependencies and Melos scripts (`melos bootstrap`, `melos run analyze`, `melos test`).
- [ ] Migrate existing code into the new packages without bloating `core`.
- [ ] Document Melos usage in contributor notes and ensure CI scripts reference it.

## Milestone 2 – Core Primitives & Event Contracts
- [ ] Implement `Failure`, `Result/Either`, IDs/time value objects inside `core/`.
- [ ] Define shared events (e.g., `CaptureItemFiled`, `FocusSessionCompleted`) consumed across slices.
- [ ] Add lightweight helpers reused by multiple slices while keeping business logic out of `core`.
- [ ] Cover invariants with unit tests.

## Milestone 3 – Infrastructure Services
- [ ] Implement Hive initialisation + encryption helpers that `app` can call at startup.
- [ ] Add secure storage wrapper (e.g., `flutter_secure_storage`) for Hive keys.
- [ ] Provide logging utilities and global error handling hooks.
- [ ] Expose notification facades for focus timers, schedule reminders, and habit nudges.
- [ ] Document Riverpod providers that slices should consume.

## Milestone 4 – App Composition & Navigation
- [ ] Configure `StatefulShellRoute` branches aligned with pillars (Capture, Plan, Execute, Review, Insights, Settings).
- [ ] Ensure each branch preserves its navigation stack when switching tabs.
- [ ] Initialise theme, ProviderScope, Hive, secure storage, and notifications in the `/app` bootstrap.
- [ ] Add placeholder routes/screens for each branch to unblock feature integration.

## Milestone 5 – Feature: Ingest
### Domain (`features/ingest/domain`)
- [ ] Define `CaptureItem` entity with validation and context metadata.
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

## Historical Layered Checklist (Archived 2025-09-29)
This section preserves the original layered roadmap snapshot (with legacy feature names) so past progress remains visible. Continue tracking new work in the milestone list above; only update these items if you need to correct historical records. The tasks below intentionally reference the former layered `packages/...` layout for archival accuracy.

### Phase 1 – Project Initialization and Setup
- [x] 1. Initialize Git repository
- [x] 2. Create Flutter project skeleton
- [x] 3. Add project-specific README with overview, setup, and license info
- [x] 4. Add MIT LICENSE file
- [x] 5. Customize `.gitignore` for Flutter project needs
- [x] 6. Configure `analysis_options.yaml` with strict linting rules (e.g., `very_good_analysis`)
- [x] 7. Adopt dependency policy and create `docs/development/dependency-log.md`
- [ ] 8. Add core dependencies only when required by tasks (see per-layer guidance)
- [x] 9. Create `packages/` directory structure for architecture layers
- [ ] 10. Configure top-level `pubspec.yaml` with path dependencies to the new packages
- [ ] 11. Add `CONTRIBUTING.md` with guidelines and workflow expectations

### Phase 2 – Domain Layer Implementation
- [ ] 12. Add dependencies to `packages/core/pubspec.yaml` (e.g., `fpdart`)
- [ ] 13. Implement base entity abstraction in `packages/core`
- [ ] 14. Create `Task` entity with required fields
- [ ] 15. Create `Goal` entity applying SMART structure
- [ ] 16. Define `EisenhowerQuadrant` enum
- [ ] 17. Create `Habit` entity with streak tracking fields
- [ ] 18. Define `TimeBlock` and `PomodoroSession` entities
- [ ] 19. Create `Review` entity for periodic reflections
- [ ] 20. Implement `Failure` hierarchy for domain errors
- [ ] 21. Add `AddTaskUseCase`
- [ ] 22. Add `CreateSmartGoalUseCase`
- [ ] 23. Add `PrioritizeWithEisenhowerUseCase`
- [ ] 24. Add `AddHabitUseCase`
- [ ] 25. Add `ScheduleTimeBlockUseCase`
- [ ] 26. Add `StartPomodoroUseCase`
- [ ] 27. Add `PerformReviewUseCase`
- [ ] 28. Add `TaskRepository` interface
- [ ] 29. Add `GoalRepository` interface
- [ ] 30. Add `HabitRepository` interface
- [ ] 31. Add any additional repository interfaces needed (e.g., Pomodoro, Reviews)

### Phase 3 – Data Layer Implementation
- [ ] 32. Add Hive and related dependencies to `packages/data/pubspec.yaml`
- [ ] 33. Implement Hive initialization utility
- [ ] 34. Create `TaskModel` DTO with Hive annotations
- [ ] 35. Create `GoalModel` DTO
- [ ] 36. Create `HabitModel` DTO
- [ ] 37. Create `TimeBlockModel` DTO
- [ ] 38. Create `PomodoroSessionModel` DTO
- [ ] 39. Create `ReviewModel` DTO
- [ ] 40. Implement `TaskLocalDataSource`
- [ ] 41. Implement `GoalLocalDataSource`
- [ ] 42. Implement `HabitLocalDataSource`
- [ ] 43. Implement `TimeBlockLocalDataSource`
- [ ] 44. Implement `PomodoroLocalDataSource`
- [ ] 45. Implement `ReviewLocalDataSource`
- [ ] 46. Implement `TaskRepositoryImpl`
- [ ] 47. Implement `GoalRepositoryImpl`
- [ ] 48. Implement `HabitRepositoryImpl`
- [ ] 49. Implement `TimeBlockRepositoryImpl`
- [ ] 50. Implement `PomodoroRepositoryImpl`
- [ ] 51. Implement `ReviewRepositoryImpl`

### Phase 4 – Infrastructure Layer
- [ ] 52. Add infrastructure dependencies (`logger`, `flutter_secure_storage`, etc.)
- [ ] 53. Implement dependency injection setup with GetIt + Injectable
- [ ] 54. Add logging utilities
- [ ] 55. Implement local notifications service
- [ ] 56. Add shared extensions/utilities
- [ ] 57. Implement global error handling utilities
- [ ] 58. Add configuration management (env/flavors)
- [ ] 59. Add analytics or monitoring hooks (optional per roadmap)
- [ ] 60. Document infrastructure usage patterns
- [ ] 61. Add infrastructure-layer tests

### Phase 5 – Presentation Layer and UI
- [ ] 62. Add UI/state management dependencies to `packages/presentation`
- [ ] 63. Implement app theming (Material 3 + FlexColorScheme)
- [ ] 64. Configure navigation with GoRouter
- [ ] 65. Build dashboard screen skeleton
- [ ] 66. Implement task capture UI components
- [ ] 67. Implement task capture state providers
- [ ] 68. Implement SMART goals UI components
- [ ] 69. Implement SMART goals state providers
- [ ] 70. Implement Eisenhower matrix UI components
- [ ] 71. Implement Eisenhower matrix state providers
- [ ] 72. Implement habit tracking UI components
- [ ] 73. Implement habit tracking state providers
- [ ] 74. Implement time blocking UI components
- [ ] 75. Implement time blocking state providers
- [ ] 76. Implement Pomodoro timer UI components
- [ ] 77. Implement Pomodoro state providers
- [ ] 78. Implement periodic review UI components
- [ ] 79. Implement periodic review state providers
- [ ] 80. Integrate analytics/gamification widgets
- [ ] 81. Implement dashboard summaries/metrics
- [ ] 82. Add settings/customization UI
- [ ] 83. Add accessibility features to UI components
- [ ] 84. Add localization/i18n scaffolding
- [ ] 85. Add shared/common widgets library
- [ ] 86. Wire presentation layer to domain use cases for core flows
- [ ] 87. Integrate notifications with UI (e.g., reminders)
- [ ] 88. Implement offline-first UX cues (sync indicators, etc.)
- [ ] 89. Optimize UI performance (const widgets, memoization)
- [ ] 90. Conduct UI polish pass (animations, theming tweaks)
- [ ] 91. Document presentation layer patterns and guidelines

### Phase 6 – Testing and CI/CD
- [ ] 92. Add unit tests for domain layer (e.g., `AddTaskUseCase`)
- [ ] 93. Expand domain unit test coverage
- [ ] 94. Add unit tests for data layer repositories
- [ ] 95. Add unit tests for infrastructure utilities
- [ ] 96. Add widget tests for critical UI components
- [ ] 97. Add dashboard widget/integration test
- [ ] 98. Add end-to-end workflow integration test (task → Pomodoro)
- [ ] 99. Add integration test for habit tracking flow
- [ ] 100. Add integration test for periodic reviews
- [ ] 101. Configure GitHub Actions CI pipeline (lint, test, coverage)

### Phase 7 – Polish and Release
- [ ] 102. Add additional accessibility enhancements
- [ ] 103. Integrate calendar sync (e.g., Google/Outlook)
- [ ] 104. Prepare beta testing build and feedback loop
- [ ] 105. Address beta feedback fixes
- [ ] 106. Prepare `v0.1.0` release (changelog, versioning)
- [ ] 107. Publish release to GitHub and relevant stores

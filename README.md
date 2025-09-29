# CascadeFlow Productivity App

CascadeFlow is an open-source productivity companion that helps people capture ideas, turn them into actionable goals, and stay accountable through habits, planning, and focused work sessions. The app is built with Flutter and aims to provide a privacy-first, offline-friendly experience across mobile, desktop, and web.

## Why CascadeFlow?
- Combine trusted productivity methods—SMART goals, the Eisenhower matrix, Pomodoro timers, habit tracking, and regular reviews—inside one seamless workflow.
- Keep data on-device by default while leaving room for optional sync integrations later on.
- Offer an accessible, customisable alternative to subscription tools through a permissive MIT licence.

## Core Workflow
1. **Capture** – Quickly jot down ideas, tasks, or distractions so nothing slips through the cracks.
2. **Clarify & Prioritise** – Refine items into SMART goals and organise them with the Eisenhower matrix.
3. **Plan** – Block time on the calendar, schedule habits, and prep focused work sessions with Pomodoro timers.
4. **Execute & Reflect** – Track streaks, review progress, and adapt plans with weekly or custom reflections.

## Feature Pillars
- **Ingest** – lightning-fast capture via widgets, quick-add, or voice so ideas land in a single inbox.
- **Goals** – SMART-style refinement that keeps long-term objectives actionable.
- **Prioritize** – decision tooling (Eisenhower, scoring, suggestions) to spotlight what matters right now.
- **Tasks** – robust task CRUD with metadata, subtasks, and completion tracking.
- **Habits** – recurring routines with streaks, cadence rules, and nudges.
- **Schedule** – calendar/time-blocking surface that balances workload across the week.
- **Focus** – execution helpers such as Pomodoro-style timers and distraction-free modes.
- **Review** – periodic retrospectives that summarise progress and guide adjustments.
- **Metrics** – dashboards and charts that surface behavioural trends.
- **Insights** – recommendations and alerts when patterns need attention.
- **Integrations** – calendar sync, import/export, feature toggles, and preferences to fit personal workflows.

## Architecture at a Glance
CascadeFlow now uses a feature-based Clean Architecture managed by Melos:
- `app/` bootstraps Flutter, ProviderScope, theming, navigation (`StatefulShellRoute`), and startup initialisation.
- `core/` stays intentionally tiny, housing universal primitives such as `Failure`, `Result/Either`, shared value objects, and cross-feature events.
- `infrastructure/` centralises cross-cutting services (Hive init + encryption helpers, secure storage, logging, notifications) exposed via Riverpod providers.
- `features/<slice>/` packages (e.g., `features/ingest`, `features/goals`, `features/focus`) own their domain, data, and presentation folders. Each slice defines its entities/use cases, Hive adapters + repositories, and Riverpod notifiers/screens.
- Riverpod is the single source of truth for dependency injection and state; there is no GetIt wiring.

See `docs/project/architecture.md` for the full breakdown and design decisions. The active roadmap and progress trackers live in `docs/project/roadmap.md` and `docs/project/progress.md` respectively.

## Getting Started
### Prerequisites
- Flutter SDK 3.24+ with Dart 3.5+
- Android Studio, VS Code, or another Flutter-enabled editor
- A connected device or emulator for running the app

### Setup
1. Clone the repository: `git clone <repo-url>`
2. From the repository root, run `melos bootstrap`
3. Use `melos run analyze` to run static analysis across all packages
4. Launch the app from the `app/` package (e.g., `flutter run`)

> Tip: Use `melos test` to execute unit and widget tests across every slice before opening a PR.

## Roadmap & Progress
The development roadmap is maintained in `docs/project/roadmap.md`, with day-to-day progress mirrored in `docs/project/progress.md`. Ingest establishes the first end-to-end slice, with the remaining pillars following the same template.

## Contributing
Community contributions are welcome. Conventional commits, strict linting, and feature-slice ownership keep the project approachable.
- Work within a feature package whenever possible.
- Touch `core/` only when introducing primitives shared by multiple slices.
- Update `docs/development/dependency-log.md` when adding new dependencies.
- Run `melos run analyze` and `melos test` before submitting a pull request.

A refreshed `CONTRIBUTING.md` outlining the full workflow lands early in the roadmap.

## Licence
CascadeFlow is released under the MIT Licence. See `LICENSE` for details.

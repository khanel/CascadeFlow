# Productivity App Project Overview

## Project Name
**CascadeFlow** (placeholder options like "ProdFlow" or "GoalSync" remain viable until branding is finalised).

## Description
CascadeFlow is an open-source (MIT) productivity companion that guides people from quick capture through deliberate execution and reflective reviews. The app unifies trusted productivity frameworks—SMART goals, the Eisenhower matrix, habit loops, time blocking, Pomodoro timers, and periodic reviews—inside a privacy-first, offline-friendly Flutter experience. Contributors can extend or customise slices without touching unrelated features, making the project a welcoming OSS playground.

Target users include students, professionals, freelancers, and productivity enthusiasts who want a cohesive workflow without the friction of ads, subscriptions, or vendor lock-in.

## Feature Pillars
1. **Ingest** – Super-fast capture via widgets, quick-add dialogs, or voice input that funnels raw ideas into a single inbox without breaking flow.
2. **Goals** – SMART-aligned space to define ambitions, add metrics, and generate sub-goals that guide daily execution.
3. **Prioritize** – Decision tooling (Eisenhower matrix, ranking, scoring) that highlights which items deserve attention now.
4. **Tasks** – Full task lifecycle management: metadata, subtasks, statuses, tagging, and completion workflows.
5. **Habits** – Recurring routines with streak tracking, cadence rules, and reminders that reinforce behaviour over time.
6. **Schedule** – Calendar and time-blocking surfaces that allocate tasks/habits to real time, resolve conflicts, and adapt when plans slip.
7. **Focus** – Execution helpers like Pomodoro timers, distraction-limiting UIs, and break automation to stay on task.
8. **Review** – Weekly/custom retrospectives with summaries, reflection prompts, and easy carry-over or replanning.
9. **Metrics** – Dashboards and analytics (trends, distributions, streaks) exposing patterns beyond raw lists.
10. **Insights** – Recommendation engine that surfaces nudges (e.g., repeatedly postponed tasks) to reduce cognitive load.
11. **Integrations** – Calendar sync, import/export, feature toggles, and notification preferences so CascadeFlow fits diverse ecosystems.

Enhancements on the roadmap include deeper analytics, gamification hooks, multi-device sync, and accessibility-first UX.

## Technology Stack
- **Framework**: Flutter 3.27+ with Dart 3.9+ (upgrade from 3.24 to satisfy `hive_ce_flutter`).
- **State & DI**: Riverpod (Notifier/AsyncNotifier APIs) with `riverpod_annotation`/`riverpod_generator` driving typed provider codegen.
- **Workspace**: Melos orchestrates the monorepo (bootstrap, analyse, test).
- **Storage**: Hive CE (community edition) for encrypted, offline-first persistence; `flutter_secure_storage` for key handling.
- **Navigation**: GoRouter updated to `16.2.4`, leveraging `StatefulShellRoute` to preserve tab stacks on Flutter 3.29+.
- **Notifications**: `flutter_local_notifications` centralised in the infrastructure package.
- **Theming**: Material 3 with FlexColorScheme `8.0.2` (compatible with Flutter 3.24–3.27).
- **Testing**: `flutter_test`, Riverpod testing utilities, and Hive CE adapter harnesses.

## Architecture Summary
CascadeFlow follows a feature-based Clean Architecture:
- **App package (`app/`)** – Bootstraps Flutter, ProviderScope, theme, router, and top-level initialisation.
- **Core package (`core/`)** – Houses universal primitives: failures, Result/Either, shared value objects, cross-feature events.
- **Infrastructure package (`infrastructure/`)** – Supplies cross-cutting services (Hive CE init, secure storage, logging, notifications) via Riverpod providers.
- **Feature packages (`features/<slice>/`)** – Each feature encapsulates its own `domain`, `data`, and `presentation` folders. Domain entities and use cases stay local; data sources manage encrypted Hive CE boxes; presentation exposes Riverpod providers and widgets for the feature UI.

Vertical slices reduce coupling, keep `core` intentionally tiny, and map cleanly onto contributor responsibilities. Cross-slice communication happens through shared events or persisted summaries rather than direct dependencies.

## Development Status
- **Current Focus**: Restructuring the repository to the feature-slice layout, wiring Melos, and standing up the Ingest slice as the golden path.
- **Next Steps**: Finalise core primitives, infrastructure services, and Ingest; then replicate the pattern across Goals, Prioritize, Tasks, and the remaining pillars.
- **Roadmap**: Detailed milestones live in `docs/project/roadmap.md`, with day-to-day tracking in `docs/project/progress.md`.
- **Known Challenges**: Balancing slice autonomy with shared UX polish; ensuring encrypted storage remains ergonomic; keeping onboarding smooth for new contributors.

## Contribution Workflow (FOSS)
- **Repository**: Hosted on GitHub (public monorepo).
- **Setup**:
  1. Clone the repo.
  2. Run `melos bootstrap` to install dependencies across packages.
  3. Use `melos run analyze` and `melos test` before submitting changes.
- **Conventions**: Conventional Commits, strict linting, and feature-slice ownership. Touch `core/` only when types truly span slices.
- **Community**: Collaboration via GitHub issues/PRs (optional Discord planned).

CascadeFlow aims to empower individuals to design deliberate workflows while cultivating an open-source community around productivity experimentation.

# CascadeFlow Productivity App

CascadeFlow is an open-source productivity companion that helps people capture ideas, turn them into actionable goals, and stay accountable through habits, planning, and focused work sessions. The app is built with Flutter and aims to provide a privacy-first, offline-friendly experience across mobile, desktop, and web.

## Why CascadeFlow?
- Combine trusted productivity methods—SMART goals, Eisenhower matrix, Pomodoro timers, habit tracking, and regular reviews—inside one seamless workflow.
- Keep data on-device by default while leaving room for optional sync integrations later on.
- Offer an accessible, customizable alternative to subscription tools through a permissive MIT license.

## Core Workflow
1. **Capture**: Quickly jot down ideas, tasks, or distractions so nothing slips through the cracks.
2. **Clarify & Prioritize**: Refine items into SMART goals and organize them with the Eisenhower matrix.
3. **Plan**: Block time on the calendar, schedule habits, and prep focused work sessions with Pomodoro timers.
4. **Execute & Reflect**: Track streaks, review progress, and adapt plans with weekly or custom reflections.

Additional enhancements include a modular dashboard, analytics and gamification hooks, rich customization, and accessibility support.

## Architecture at a Glance
- **Clean Architecture** with domain, data, presentation, and infrastructure layers.
- Modular `packages/` structure to keep features isolated and contributor-friendly.
- Riverpod-powered state management, Hive for local persistence, and GoRouter for navigation.
- Dependency injection with GetIt/Injectable, plus logging, notifications, and utilities in the infrastructure layer.

See `docs/architecture.md` for the full breakdown and design decisions.

## Getting Started
Prerequisites:
- Flutter SDK 3.24+ with Dart 3.5+
- Android Studio or VS Code (or another editor with Flutter support)
- A connected device or emulator for running the app

Setup:
1. Clone the repository: `git clone <repo-url>`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

> Note: As of now, the repository still contains the default Flutter counter app. Follow the roadmap to evolve the structure into the full CascadeFlow architecture.

## Roadmap & Progress
The development plan is detailed in `docs/roadmap.md`. Active progress is tracked in `docs/progress.md`, which mirrors the roadmap steps as actionable todos.

## Contributing
Community contributions are welcome. Conventional commits, strict linting, and high test coverage will be enforced once the tooling and guidelines are in place. A full `CONTRIBUTING.md` file is scheduled early in the roadmap.

## License
The project is released under the MIT License. A dedicated `LICENSE` file will be added in the next roadmap step.

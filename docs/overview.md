# Productivity App Project Overview

## Project Name
**CascadeFlow** (or a placeholder; suggest alternatives like "ProdFlow" or "GoalSync" based on your preference).

## Description
CascadeFlow is an open-source (FOSS) productivity app designed to help users organize goals, tasks, and habits through a seamless integration of proven productivity methods. Built as a personal project and released under the MIT license on GitHub, it aims to provide a free, customizable tool for individuals seeking better focus, prioritization, and long-term progress tracking. The app addresses common productivity challenges like mental clutter, poor planning, and inconsistent execution by combining task management with reflective practices.

Unlike fragmented tools that focus on single methods, CascadeFlow creates a holistic workflow: capture ideas quickly, refine them into actionable goals, prioritize strategically, build habits, schedule focused work, execute with timers, and review progress periodically. It's designed for cross-platform use (mobile-first with potential web/desktop extensions) and emphasizes user privacy with offline-first functionality—no data leaves the device unless explicitly synced.

Target users include professionals, students, freelancers, and productivity enthusiasts who want a simple yet powerful app without ads or subscriptions.

## Key Features
The app integrates the following methods into a cohesive system:

1. **Task Capture ("Jot It Down")**: Quickly log tasks, goals, or distractions via text, voice, or quick-add widgets to clear your mind.
2. **SMART Goal Setting**: Refine captured items into Specific, Measurable, Achievable, Relevant, and Time-bound goals with guided prompts and AI-like suggestions.
3. **Eisenhower Matrix**: Prioritize tasks by urgency and importance using an interactive drag-and-drop matrix to focus on what matters.
4. **Habit Tracking**: Monitor recurring habits with visual streaks ("don't break the chain"), auto-scheduling, and motivational reminders.
5. **Time Blocking**: Schedule tasks and habits into calendar-integrated blocks, with smart suggestions based on availability and user patterns.
6. **Pomodoro Technique**: Execute work in focused sessions (e.g., 25/5 intervals) with timers, progress tracking, and distraction-free modes.
7. **Periodic Reviews/Reflections**: Weekly (or customizable) summaries with insights, reflection prompts, and adjustments to improve future productivity.

Additional enhancements:
- **Dashboard**: Centralized view of tasks, goals, habits, and metrics.
- **Analytics & Gamification**: Track efficiency (e.g., Pomodoro hours, streak lengths) with charts, badges, and points for motivation.
- **Customizations**: Themes, notification preferences, and modular features (enable/disable methods).
- **Integrations**: Calendar sync (Google/Outlook), wearables for habit tracking, and future API for extensions.
- **Accessibility**: Voice commands, high-contrast modes, and screen reader support.

## Technology Stack
- **Framework**: Flutter (latest stable, e.g., 3.24+) for cross-platform development (iOS, Android, web/desktop).
- **Language**: Dart 3.5+ with null-safety and modern features like records.
- **State Management**: Riverpod for efficient, type-safe reactivity.
- **Storage**: Hive (offline NoSQL) with encryption; optional remote sync (e.g., Firebase/Supabase).
- **Other Libraries**:
  - Navigation: GoRouter.
  - Notifications: flutter_local_notifications.
  - DI: GetIt + Injectable.
  - Testing: flutter_test, mockito.
  - UI: Material 3 with FlexColorScheme for theming.
- **Architecture**: Clean Architecture with modular packages for maintainability (see [Architecture Document](architecture.md) for details).

## Architecture Summary
Adopts Clean Architecture for separation of concerns:
- **Domain Layer**: Entities, use cases, repositories (pure business logic).
- **Data Layer**: Persistence and sources (Hive local, optional remote).
- **Presentation Layer**: UI features as modules with Riverpod state.
- **Infrastructure**: DI, logging, utilities.

This ensures testability (>80% coverage), scalability, and easy contributions. Folder structure uses a monorepo with packages for modularity.

## Development Status
- **Current Phase**: Planning/Architecture complete; ready for MVP implementation (start with core features like task capture and Pomodoro).
- **Roadmap**:
  1. MVP: Basic workflow (capture, prioritize, schedule, execute).
  2. Beta: Add SMART, habits, reviews; integrations.
  3. v1.0: Polish, testing, GitHub release.
  4. Future: AI enhancements, community features, web support.
- **Known Challenges**: Balancing simplicity with depth; ensuring performance on low-end devices.

## How to Get Involved (FOSS on GitHub)
- **Repository**: [github.com/yourusername/focusflow](https://github.com/yourusername/focusflow) (setup with README, CONTRIBUTING.md, and issues).
- **Setup**:
  1. Clone the repo.
  2. Run `flutter pub get`.
  3. Build with `flutter run` (emulator/device).
- **Contributions**: Welcome PRs for features, bug fixes, or docs. Follow CONTRIBUTING.md (conventional commits, linting).
- **License**: MIT – free to use, modify, and distribute.
- **Community**: Discuss on GitHub issues; potential Discord for collaborators.

This project empowers users to take control of their productivity while fostering an open-source community. If you'd like to expand on any section (e.g., detailed roadmap or mockups), let me know!

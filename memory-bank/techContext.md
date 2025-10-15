# Technical Context: CascadeFlow

## Technology Stack

### Core Platform
- **Dart**: 3.9.2+ (stable channel)
- **Flutter**: 3.24.0+ (stable channel)
- **Platform Targets**: Android, iOS, Linux, macOS, Windows

### State Management
- **Riverpod**: 3.0.1 - Primary state management solution
- **riverpod_annotation**: 3.0.1 - Code generation for providers
- **riverpod_generator**: 3.0.1 - Build runner integration
- **flutter_riverpod**: 3.0.1 - Flutter-specific Riverpod bindings

### Data Layer
- **hive_ce**: 2.14.0 - Local NoSQL database (Community Edition)
- **hive_ce_flutter**: 2.3.2 - Flutter integration for Hive CE
- **path_provider**: 2.1.5 - Platform-specific path resolution
- **flutter_secure_storage**: 9.2.4 - Encrypted key-value storage

### Functional Programming
- **fpdart**: 1.1.1 - Functional programming utilities (TaskEither, Option, etc.)

### Navigation & Routing
- **go_router**: 16.2.4 - Declarative routing with nested navigation
- **StatefulShellRoute**: Preserves tab state across navigation

### UI & Design
- **flex_color_scheme**: 8.0.2 - Material 3 theme management
- **intl**: 0.20.2 - Internationalization and localization
- **flutter_local_notifications**: 19.4.2 - Local notification scheduling

### Infrastructure
- **logger**: 2.6.1 - Structured logging
- **build_runner**: 2.8.0 - Code generation tooling

## Development Environment

### IDE & Tools
- **VS Code**: Primary development environment
- **Flutter SDK**: Managed via FVM (Flutter Version Management)
- **Dart SDK**: Included with Flutter
- **Android Studio**: Android development and emulation

### Package Management
- **Pub**: Dart package manager
- **Pubspec.yaml**: Dependency declarations with version constraints
- **Pubspec.lock**: Lockfile for reproducible builds

### Build System
- **Flutter Build**: Cross-platform compilation
- **Gradle**: Android build system
- **Xcode**: iOS/macOS build system
- **CMake**: Linux/Windows native builds

## Technical Constraints

### SDK Requirements
- Minimum Dart SDK: 3.9.2
- Minimum Flutter SDK: 3.24.0
- Some packages require Flutter 3.27+ (noted in dependency matrix)

### Platform Limitations
- iOS deployment requires Apple Developer Program
- Windows/Linux builds require platform-specific development tools
- Some packages have platform-specific implementations

### Performance Considerations
- Flutter's single-threaded UI with background isolates for heavy computation
- Hive performance characteristics for local data storage
- Memory management for large datasets

## Dependencies Strategy

### Selection Criteria
- **Flutter Favorite** status where available
- Active maintenance and community support
- Compatibility with target SDK versions
- Minimal transitive dependencies

### Version Management
- Explicit version pins in pubspec.yaml
- Regular dependency audits via `flutter pub outdated`
- Upgrade planning documented in dependency matrix
- Security updates prioritized

### Alternative Packages
- **Hive CE** replaces original Hive for Dart 3+ compatibility
- **Riverpod** chosen over GetIt/Provider for type safety and testability
- **go_router** selected over auto_route for simpler API

## Development Workflow

### Code Generation
- `build_runner watch` for continuous regeneration
- Generated files committed to version control
- Part files for provider and adapter generation

### Testing Strategy
This project mandates a strict Test-Driven Development (TDD) process for all code changes. All development must follow the **Red-Green-Refactor** cycle, with each phase committed separately. This is a core requirement for maintaining code quality and stability.

Refer to `systemPatterns.md` for a detailed breakdown of this mandatory workflow.


### Code Quality
- `flutter analyze` for static analysis
- Custom analysis_options.yaml rules
- Pre-commit hooks for quality gates
# Active Context: CascadeFlow

## Current Development Focus

### Primary Feature: Ingest
- **Status**: Active development
- **Scope**: Capture item management with inbox functionality
- **Current Work**: Presentation coverage and swipe gestures for inbox management
- **Open Files**: `capture_inbox_list.dart`, archive/delete gesture tests

### Architecture Implementation
- **Feature-Sliced Design**: Modular packages with clear boundaries
- **Riverpod Integration**: Code-generated providers with annotation-based setup
- **Infrastructure Stubs**: In-memory implementations for early development

## Recent Changes

### Quick Entry Controller Validation
- Moved quick entry validation from the widget to the controller layer
- Controller now returns a `ValidationFailure` for empty or whitespace-only input
- Added dedicated controller tests to cover validation scenarios

### Provider Registry
- Infrastructure providers established for storage and logging
- In-memory Hive initializer for development testing
- Secure storage stub for key management
- Archive use case provider exposed for presentation layer overrides

### Core Domain Events
- `DomainEvent` base class for event-driven architecture
- Specific events: `CaptureItemArchived`, `CaptureItemFiled`, `FocusSessionCompleted`
- Event system foundation for cross-feature communication

### Dependency Updates
- Migrated from `hive` to `hive_ce` for Dart 3.9+ compatibility
- Updated `go_router` to latest version (16.2.4)
- Maintained compatibility with Flutter 3.24+ constraints

### Presentation Test Coverage
- Added provider-level tests for `CaptureQuickEntryController` success and failure paths
- Added widget tests for `CaptureInboxList` covering loading, empty, data, and error states
- Added widget tests for `CaptureQuickAddSheet` covering submission lifecycle and error handling
- Added gesture tests validating archive undo flow and delete confirmations

### Capture Inbox Gestures & Data Flow
- Pagination now handled by `CaptureInboxPaginationController`, exposing `CaptureInboxPaginationState` for infinite scrolling and load-more indicators
- Pagination controller now guards its initial load Future and uses state helpers (`beginLoadMore`, `append`, `withLoadMoreError`) to keep repeated rebuilds and gesture-driven reloads stable
- Inbox items rendered with `Dismissible` supporting archive (start-to-end) and delete (end-to-start) gestures
- Archive action persists via `ArchiveCaptureItem` use case, invalidates inbox provider, and exposes undo snackbar
- Delete action confirms via dialog, cascades repository delete, and reports failures with snackbar messaging
- Provider container used for safe invalidation when widget is disposed, avoiding `ref` access in delayed callbacks
- Gesture orchestration centralized in `_CaptureInboxActions` to capture dependencies eagerly and remove duplicated snackbar logic
- Repository now delivers inbox items sorted by newest-first timestamps to prioritize fresh captures
- Repository results wrapped in `List.unmodifiable` to guard against accidental mutation by consumers
- `CaptureRepository.loadInbox` accepts an optional `limit` enabling batched fetches for large inboxes
- `captureInboxItemsProvider` now requests 50-item batches by default to keep UI updates snappy
- `captureInboxPageProvider` exposes paginated inbox loading with `limit`/`startAfter` arguments for incremental fetches
- `CaptureRepository.loadInbox` also respects `startAfter` cursors so pagination resumes after the last item returned
## Active Decisions

### State Management Pattern
- **Chosen**: Riverpod with code generation
- **Rationale**: Type safety, testability, and reduced boilerplate
- **Implementation**: `@riverpod` annotations with `build_runner` generation

### Storage Strategy
- **Chosen**: Hive CE with encrypted boxes
- **Rationale**: NoSQL flexibility, offline-first, cross-platform
- **Security**: AES encryption with keys stored in secure storage

### Navigation Architecture
- **Chosen**: go_router with StatefulShellRoute
- **Rationale**: Preserves tab state, nested navigation support
- **Implementation**: Tab-based navigation with stack preservation

## Current Patterns & Preferences

### Code Organization
- **Domain First**: Business logic before UI implementation
- **Functional Core**: Pure functions with side effects at boundaries
- **Type Safety**: Strong typing throughout with generated code

### Testing Approach
- **Strict Test-Driven Development**: All development **must** follow the Red-Green-Refactor TDD cycle. Each phase (Red, Green, Refactor) is an atomic, separate commit. This is a mandatory workflow for all new features and bug fixes.
- **Unit Tests**: Domain logic and providers are built using the TDD cycle.
- **Widget Tests**: UI component integration is developed with behavior-driven tests, also following the TDD cycle.
- **Integration Tests**: Feature workflows are validated with end-to-end tests.
- **Stubs**: In-memory implementations are used for isolated testing.

### Error Handling
- **Domain Layer**: `TaskEither<Failure, Result>` pattern
- **Presentation Layer**: Provider state with error states
- **User Experience**: Graceful error messages and recovery options

## Next Steps

### Immediate Priorities
1. Complete ingest feature implementation
2. Establish focus session management
3. Implement review workflow foundation
4. Add comprehensive testing coverage

### Technical Debt
- Replace infrastructure stubs with real implementations
- Implement proper error boundaries in UI
- Add performance monitoring and optimization
- Establish CI/CD pipeline

### Feature Roadmap
- **Phase 1**: Core capture and focus workflows
- **Phase 2**: Review and analytics features
- **Phase 3**: Advanced scheduling and insights
- **Phase 4**: Multi-device synchronization

## Known Issues & Blockers

### Current Limitations
- Infrastructure layer uses in-memory stubs
- No real data persistence yet
- Limited error handling in UI components
- Basic theming without full Material 3 implementation

### External Dependencies
- Some packages require Flutter 3.27+ for full compatibility
- Platform-specific implementations pending
- Notification permissions not yet handled

## Development Environment

### Active Tools
- VS Code with Flutter extensions
- Build runner for code generation
- Hot reload for rapid iteration
- Test runner for continuous validation

### Workflow Preferences
- Feature-branch development
- Pull request reviews for quality control
- Automated testing on commits
- Documentation updates with code changes

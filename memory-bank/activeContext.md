# Active Context: CascadeFlow

## Current Development Focus

### Primary Feature: Ingest - Deep Review Complete
- **Status**: 🟡 Technical Debt Identified - Comprehensive review complete
- **Previous Issue**: The data layer implementation did not fully align with the `ingest-plan.md`.
- **Next**: Address the identified technical debt in the data layer, and implement missing features in the presentation and domain layers.

### Architecture Implementation
- **Feature-Sliced Design**: Modular packages with clear boundaries
- **Riverpod Integration**: Code-generated providers with annotation-based setup
- **Infrastructure Stubs**: In-memory implementations for early development

## Recent Changes

### Capture Inbox Filing Gesture
- Added long-press gesture to inbox items to trigger filing workflow
- Followed TDD cycle, starting with a failing widget test for the dialog
- Implemented a confirmation dialog to prevent accidental filing
- Integrated the UI with the `FileCaptureItem` use case
- Added `fileCaptureItemUseCaseProvider` to the presentation layer

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
- Added widget tests verifying capture inbox filtering by source and channel chips

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

### Capture Inbox Filtering Controls
- Added `CaptureInboxFilterController` provider to manage source/channel selections
- Introduced filter chip bar with "All sources" and "All channels" toggles plus dynamic chip lists
- Updated inbox list to apply filters before rendering and show a filtered-empty state when no items match
- Extended pagination list to request additional pages when filtered results are scrolled to the threshold
- Refactored filter controller to short-circuit redundant updates and split inbox list rendering into focused widgets for maintainability
- Persisted filter selections via `CaptureInboxFilterStore` using secure storage stubs, restoring them on controller bootstrap and syncing updates automatically

### Capture Inbox Filter Presets
- Added `CaptureFilterPreset` model for saving and loading custom filter configurations
- Implemented preset management in `CaptureInboxFilterStore` with save, load, delete, and clear operations
- Added comprehensive error handling for preset operations with `FilterPresetException`
- Enhanced filter store with constants, improved serialization, and robust error handling
- Followed TDD cycle: tests first (failing tests for presets), then implementation, then refactoring with error handling

### Capture Domain Status Helpers
- `CaptureItem` exposes `isInbox`, `isFiled`, and `isArchived` getters to reduce direct status comparisons throughout the domain layer
- Filing workflow implemented via `FileCaptureItem` use case, transitioning items to the new `CaptureStatus.filed` state while emitting `CaptureItemFiled` events

### Blue Phase Refactoring Completion
- **Status**: ✅ Complete - all 72 tests passing
- **Technical Debt Addressed**:
  - Extracted common error handling in `CaptureInboxFilterStore.load/loadPresets` into generic `_loadWithDefault<T>()` helper
  - Simplified preset menu building in `_CaptureInboxFilterBar` with cleaner menu item construction
  - Eliminated redundant try-catch patterns in `CaptureFilterPresetController` with `_performPresetOperation()` helper
  - Fixed unused catch clause warning and code style issues
- **Code Quality Improvements**: Reduced duplication, enhanced readability, improved maintainability while preserving 100% functionality
- **Verification**: Flutter analyze reports only minor style warnings, flutter test shows "All tests passed!"
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
- **Ingest Data Layer (High Priority):**
  - Refactor `CaptureLocalDataSource` to return `Result` types.
  - Optimize `CaptureRepositoryImpl.loadInbox` to use Hive queries.
  - Implement explicit error handling in `CaptureRepositoryImpl`.
  - Add data migration helpers.
- **Ingest Presentation Layer (Medium Priority):**
    - Implement keyboard shortcuts for the quick-add sheet.
    - Add a voice capture stub to the UI.
    - Implement golden tests for UI consistency.
- **Ingest Domain Layer (Low Priority):**
    - Implement the "optional attachments descriptor" in the `CaptureItem` entity.
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

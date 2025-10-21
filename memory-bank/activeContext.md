# Active Context: CascadeFlow

## Current Development Focus

### Phase Research Notes
- **RED – Capture local read/delete Result tests (2024-11-25)**
  - Sources:
    - Dart team, “Dart testing overview” – https://dart.dev/guides/testing
    - Flutter team, “An introduction to unit testing” – https://docs.flutter.dev/cookbook/testing/unit/introduction
  - Takeaways:
    - Give tests intent-revealing descriptions tied to the observable behaviour so failures identify the scenario immediately.
    - Follow Arrange/Act/Assert structure with explicit setup inside each test to avoid hidden coupling across cases.
    - Simulate async failures using `Future.error` so both error and stack trace can be asserted on the resulting `InfrastructureFailure`.
    - Await the SUT call before matching on `Result` objects to ensure thrown errors do not bypass expectations.
    - Use type-safe matchers such as `isA<FailureResult<...>>` plus `same(error)` to confirm cause preservation.
  - Reuse: See `researchIndex.md › Capture Local Data Source Result Handling`.
- **RED – Wrap capture data source operations in `Result`**
  - Sources:
    - Dart team, “Futures and error handling” – https://dart.dev/guides/libraries/futures-error-handling
    - Flutter API docs, “FlutterError class” – https://api.flutter.dev/flutter/foundation/FlutterError-class.html
  - Takeaways:
    - Prefer `try`/`catch` around awaited futures so asynchronous exceptions surface synchronously before wrapping them in domain-friendly results.
    - Preserve original stack traces when mapping errors into project-specific `Failure` types to avoid losing debugging context.
    - Provide actionable error descriptions that align with Flutter’s error reporting expectations, so downstream UI can surface meaningful diagnostics.
    - Keep error handling centralized per operation to reduce duplicated guards across callers.
  - Reuse: Covered in `researchIndex.md › Ingest Data Layer Result Wrapping` (RED section).
- **GREEN – Implement `saveResult` guard around Hive writes**
  - Sources:
    - Dart team, “Error handling” – https://dart.dev/language/error-handling
    - Hive GitHub README – https://raw.githubusercontent.com/hivedb/hive/master/README.md
  - Takeaways:
    - Use `try`/`catch` with `rethrow`-like preserving of `cause` to maintain original error context while mapping to domain failures.
    - Ensure asynchronous Hive writes are awaited so thrown errors propagate into our guard logic instead of being dropped on microtask queues.
    - Provide operation-specific failure messages (e.g., “save capture model”) to make debugging storage issues easier.
    - Keep Hive initialization idempotent and reuse opened boxes to avoid state churn during repeated write attempts.
  - Reuse: See `researchIndex.md › Ingest Data Layer Result Wrapping` (GREEN section).
- **BLUE – Consolidate capture error handling helpers (2024-11-25)**
  - Sources:
    - Refactoring.Guru, “What is Refactoring?” – https://refactoring.guru/refactoring/what-is-refactoring
    - Dart team, “Effective Dart: Design” – https://dart.dev/effective-dart/design
  - Takeaways:
    - Collapse duplicate error translation helpers into a single operation-aware method to keep behaviour consistent across save/read paths.
    - Feed operation descriptors into the helper rather than hardcoding message strings in multiple places.
    - Introduce shared expectation utilities in tests to enforce uniform assertions and reduce duplication.
    - Keep refactors incremental with tests run between changes for safety.
  - Reuse: Logged in `researchIndex.md › Capture Local Data Source Result Handling`.

### Primary Feature: Ingest - Deep Review Complete
- **Status**: 🟡 Technical Debt Identified - Comprehensive review complete
- **Previous Issue**: The data layer implementation did not fully align with the `ingest-plan.md`.
- **Next**: Address the identified technical debt in the data layer, and implement missing features in the presentation and domain layers.

### Architecture Implementation
- **Feature-Sliced Design**: Modular packages with clear boundaries
- **Riverpod Integration**: Code-generated providers with annotation-based setup
- **Infrastructure Stubs**: In-memory implementations for early development

## Recent Changes

### Ingest Data Layer Result Wrappers
- Added `CaptureLocalDataSource.saveResult` to wrap Hive writes in `Result<void, InfrastructureFailure>` and preserve original error context.
- Introduced `_wrapSaveError` helper so existing infrastructure failures retain stack traces while new failures use consistent messaging.
- Added regression test `saveResult wraps hive write failures in InfrastructureFailure` to guarantee the guard path and error metadata.
- Documented supporting research in `researchIndex.md › Ingest Data Layer Result Wrapping`; revisit or prune when ingest storage priorities shift.

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

### Platform Storage Overrides
- Added `createStorageOverridesForPlatform` to supply platform-aware overrides for storage during app bootstrap
- `CascadeBootstrap` now injects persistent `RealHiveInitializer` and `FlutterSecureStorageAdapter` implementations on Android, iOS, macOS, Windows, and Linux
- Introduced `SecureStorage` abstraction with both in-memory and Flutter-backed adapters
- Added widget-level tests (`app/test/storage_overrides_test.dart`) covering platform selection and verifying Hive persistence across container restarts
- Blue refactor tightened platform override logic (reused `RealHiveInitializer.new`/`FlutterSecureStorageAdapter.new`) and extracted shared test helpers for clearer expectations
- Real Hive initializer now accepts the `SecureStorage` abstraction (defaulting to `FlutterSecureStorageAdapter`), letting tests inject `InMemorySecureStorage` without touching plugin channels; corresponding test helpers reuse shared storage instances to simulate app restarts
- App bootstrap is now gated behind `runCascadeBootstrap`, showing a loading scaffold while adapters/boxes initialize; tests pump `CascadeBootstrap(isWebOverride: true)` instead of wiring storage overrides manually

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

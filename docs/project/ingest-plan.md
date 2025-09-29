# Ingest Slice Implementation Plan

## Objective
Stand up the Ingest feature slice as the first vertical implementation, proving the feature-based Clean Architecture flow from domain → data → presentation with tight event integration and offline-friendly storage.

## Dependencies
- Core primitives (`Failure`, `Result`, value objects, shared events) in `packages/core` ✅
- Workspace tooling (`melos.yaml`, path dependencies) ✅
- Feature package scaffolding (`features/ingest/...`) ⏳
- Infrastructure services for encrypted Hive and secure storage (Milestone 3) ⏳

## Domain Layer (`features/ingest/domain`)
1. **Entities & Value Objects**
   - `CaptureItem` with fields: `id`, `content`, `context` (source app, channel), `createdAt`, `updatedAt`, `status` (inbox, archived), optional `metadata` map.
   - Value objects for `CaptureSource` (enum-like), `CaptureStatus`, and optional attachments descriptor.
2. **Use Cases**
   - `CaptureQuickEntry` (validates input, assigns defaults, emits `CaptureItemFiled`).
   - `ArchiveCaptureItem` (moves item from inbox to archive, records timestamp, emits archival event placeholder).
   - Future hook: `CaptureVoiceEntry` (bounded to TODO until voice infra arrives).
3. **Validation Rules**
   - Reject empty content and enforce trimmed strings.
   - Restrict metadata keys to snake_case (sanity check for storage consistency).
   - Ensure invariants with unit tests using TDD per commit flow.
4. **Testing Strategy**
   - Unit tests per use case covering success/failure paths.
   - Entity invariants (factory validation, status transitions).

## Data Layer (`features/ingest/data`)
1. **Storage Setup**
   - Hive box: `capture_items` (encrypted, lazy support).
   - DTO/Adapter `CaptureItemModel` with `HiveType` annotations.
   - Migration helpers for future schema bumps.
2. **Data Sources**
   - `CaptureLocalDataSource` with CRUD operations, returning `Result` types.
   - Optional `CaptureVoiceTranscriptionDataSource` placeholder (deferred).
3. **Repository Implementation**
   - `CaptureRepositoryImpl` bridging domain use cases to data source.
   - Uses infrastructure-provided encryption helpers & secure storage.
4. **Tests**
   - Hive integration tests using temp directories and secure key stubs.
   - Repository tests verifying mapping and error propagation.

## Presentation Layer (`features/ingest/presentation`)
1. **State Management**
   - Riverpod providers: `captureQuickEntryController`, `inboxItemsProvider`, `archiveActionController`.
   - Base `CaptureFormState` (idle, submitting, success, error).
2. **UI Components**
   - Quick-add sheet (text entry) with keyboard shortcuts.
   - Voice capture stub (disabled until voice infra ready) with clear TODO markers.
   - Inbox list with filtering by context/source, swipe-to-archive.
3. **Routing**
   - Placeholder route `/capture` integrated into app shell (Milestone 4 dependency).
4. **Testing**
   - Widget tests for quick-add flow and inbox list rendering.
   - Golden tests optional (defer until design stable).

## Cross-Cutting Considerations
- Emit `CaptureItemFiled` event on successful quick entry for Insights/Goals slices.
- Consider analytics hooks once Metrics slice is active.
- Document dependency additions (e.g., `flutter_hooks`, `speech_to_text`) in dependency log when introduced.

## Execution Checklist
- [ ] Scaffold feature package folders (`features/ingest/{domain,data,presentation}`).
- [ ] Apply TDD commit cadence (tests → implementation → refactor) per task above.
- [ ] Update progress tracker after domain and data layers land.
- [ ] Coordinate with Milestone 3 to wire Hive/secure storage before integration tests.

## Open Questions
- Do we require offline voice entry MVP or defer to post-MVP?
- Which metadata fields must sync with downstream slices (Goals/Prioritize) at creation time?
- How aggressively should we deduplicate capture content before storage?

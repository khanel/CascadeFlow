# Research Index

This file is the canonical catalog of reusable research. Consult it before beginning any new phase-specific investigation. If an entry already covers the current task (technology, pattern, and time frame), reference that entry in phase notes and reuse the guidance. Only perform new research when a gap exists, then add the fresh findings here so future phases can benefit.

## Entry Template

For every research effort, add or update an entry using the following structure (keep the headings as-is):

````markdown
### Topic: <concise subject> _(use consistent titles so future notes can cite them verbatim)_
- Feature / Area: <feature, layer, or component names>
- Last Updated: YYYY-MM-DD
- References:
  - Cite this entry in phase notes as “researchIndex.md › `<topic>`”

#### RED Guidance
- Summary:
  - RED-specific learnings (test design intent, immediate future considerations)
- Key Practices:
  - Bullet list tailored to RED work
- Source Index:
  - [Title](URL) — why this source informs RED
- Reuse Notes:
  - When to revisit RED guidance, known limitations

#### GREEN Guidance
- Summary:
  - GREEN implementation insights and near-term extensions
- Key Practices:
  - Bullet list tailored to GREEN work
- Source Index:
  - [Title](URL) — why this source informs GREEN
- Reuse Notes:
  - When to refresh GREEN guidance, assumptions to watch

#### BLUE Guidance
- Summary:
  - BLUE refactoring and quality considerations
- Key Practices:
  - Bullet list tailored to BLUE work
- Source Index:
  - [Title](URL) — why this source informs BLUE
- Reuse Notes:
  - When to revisit BLUE guidance, contexts that may invalidate it
````

## Entries

### Topic: Ingest Data Layer Result Wrapping
- Feature / Area: Ingest › Data Layer › Hive persistence
- Last Updated: 2024-11-24
- References:
  - Cite this entry in phase notes as “researchIndex.md › Ingest Data Layer Result Wrapping”

#### RED Guidance
- Summary:
  - Focus tests on validating result wrappers capture Hive write failures and surface infrastructure-level detail without breaking existing APIs.
  - Plan ahead for pagination and repository updates so test data builders stay reusable across near-term ingest tasks.
- Key Practices:
  - Build failing tests around `Result<void, InfrastructureFailure>` expectations, asserting preserved causes/stack traces.
  - Use deterministic Hive fakes or throwers to verify guard behavior before implementation.
- Source Index:
  - [Futures and error handling](https://dart.dev/guides/libraries/futures-error-handling) — outlines capturing async errors via `try`/`catch` and `Future.sync`.
  - [FlutterError class](https://api.flutter.dev/flutter/foundation/FlutterError-class.html) — emphasizes preserving stack traces and meaningful messages for debugging.
- Reuse Notes:
  - Revisit when expanding tests beyond save operations (e.g., read/update) or when Hive API changes; otherwise reuse for similar failure-wrapping tests.

#### GREEN Guidance
- Summary:
  - Implement minimal wrappers using `Result.guardAsync`, ensuring Hive initialisation stays idempotent and error metadata remains intact.
  - Anticipate upcoming repository integration so helper methods (_wrapSaveError) stay private and reusable.
- Key Practices:
  - Await Hive writes and wrap them via `Result.guardAsync` with context-rich messages.
  - Normalize existing `InfrastructureFailure` instances to keep stack traces while avoiding duplicate logging.
- Source Index:
  - [Error handling](https://dart.dev/language/error-handling) — recommends clear `try`/`catch` usage and preserving error context.
  - [Hive README](https://raw.githubusercontent.com/hivedb/hive/master/README.md) — documents synchronous nature of writes and need for controlled access.
- Reuse Notes:
  - Refresh when migrating from in-memory to production Hive adapters or when adding transaction support; guidance applies to all ingest write paths.

#### BLUE Guidance
- Summary:
  - Refactor shared helpers (_wrapSaveError) to reduce duplication, and ensure documentation plus research index remain aligned with broader ingest roadmap.
  - Prepare for future phases that will add similar wrappers for read/delete operations to maintain consistency.
- Key Practices:
  - Keep private helpers small, intent-revealing, and thoroughly covered by tests.
  - Update activeContext summaries and prune index entries when no longer needed for near-term ingest work.
- Source Index:
  - [Effective Dart: Style](https://dart.dev/effective-dart/style) — supports intent-revealing names and consistent structure.
  - [Effective Dart: Design](https://dart.dev/effective-dart/design) — guides API surface minimisation and reuse.
- Reuse Notes:
  - Re-evaluate after repository integration or when refactoring cross-feature storage patterns; remove if ingest focus shifts away from Hive result handling.

### Topic: Capture Local Data Source Result Handling
- Feature / Area: Ingest › Data Layer › CaptureLocalDataSource
- Last Updated: 2024-11-25
- References:
  - Cite this entry in phase notes as “researchIndex.md › Capture Local Data Source Result Handling”

#### RED Guidance
- Summary:
  - Extend capture data source tests to cover `Result`-returning read/delete paths by simulating Hive failures and asserting InfrastructureFailure wrapping.
- Key Practices:
  - Name tests after the observable behaviour so failing output highlights the scenario.
  - Structure each test with explicit Arrange/Act/Assert sections to minimize hidden coupling.
  - Use `Future.error` on stubbed Hive calls to preserve both error and stack trace in assertions.
  - Verify `Result` instances using `isA<FailureResult<...>>` and `same(error)` to ensure cause identity.
- Source Index:
  - [Dart testing overview](https://dart.dev/guides/testing) — covers asynchronous unit testing patterns and matcher usage.
  - [An introduction to unit testing](https://docs.flutter.dev/cookbook/testing/unit/introduction) — reinforces focused, readable test structure.
- Reuse Notes:
  - Revisit when additional data source operations gain `Result` variants or when switching persistence fakes.

#### GREEN Guidance
- Summary:
  - Implement `Result` wrappers for read/delete using existing box access helpers while keeping the outward API compatible for existing callers.
- Key Practices:
  - Reuse `_useBox` and `Result.guardAsync` to centralise Hive error handling.
  - Preserve stack traces when mapping exceptions into `InfrastructureFailure`.
  - Expose new `Result` helpers alongside existing void/nullable methods to avoid breaking consumers.
- Source Index:
  - [Dart testing overview](https://dart.dev/guides/testing) — documents async error propagation informing guard implementation.
  - [An introduction to unit testing](https://docs.flutter.dev/cookbook/testing/unit/introduction) — encourages writing minimal code to satisfy the new contract.
- Reuse Notes:
  - Reference when introducing additional persistence operations or adapting to new storage adapters; assumptions hold while Hive APIs throw `Future` errors.

#### BLUE Guidance
- Summary:
  - Consolidate duplicated error-wrapping logic and shared test assertions so the new `Result` helpers remain maintainable without changing behaviour.
- Key Practices:
  - Extract reusable assertion helpers for InfrastructureFailure expectations across tests.
  - Align helper signatures with operation semantics instead of duplicating message strings.
  - Apply refactors incrementally, running tests after each change.
- Source Index:
  - [What is Refactoring?](https://refactoring.guru/refactoring/what-is-refactoring) — emphasises removing duplication while keeping behaviour unchanged.
  - [Effective Dart: Design](https://dart.dev/effective-dart/design) — guides intent-revealing helper design and consistent APIs.
- Reuse Notes:
  - Apply during future refactors touching capture storage error handling or when porting patterns to other features’ data layers.

### Topic: Hive Data Migration
- Feature / Area: Infrastructure › Storage › Hive
- Last Updated: 2025-10-21
- References:
 - Cite this entry in phase notes as “researchIndex.md › Hive Data Migration”

#### RED Guidance
- Summary:
 - Develop tests that simulate schema changes in Hive models and expect the migration helper to correctly transform old data to the new format.
 - Focus on verifying the migration logic correctly handles missing fields, type changes, and data transformations.
- Key Practices:
 - Create a test setup that initializes Hive with an older schema version.
 - Write a test that attempts to open the box with the new schema and asserts that the migration process is triggered and successful.
 - Use mock data representing the old schema and assert that the migrated data matches the expected new schema.
 - Ensure tests cover various migration scenarios, including adding new fields, removing old fields, and changing field types.
- Source Index:
 - [Hive CE Migration Documentation](https://docs.hivedb.dev/#/hive_ce/migrations) — official guide on how to handle schema migrations with Hive CE.
 - [Effective Dart: Testing](https://dart.dev/effective-dart/testing) — general Dart testing best practices.
- Reuse Notes:
 - Revisit when planning migrations for other Hive boxes or when Hive CE introduces new migration features.

#### GREEN Guidance
- Summary:
 - Implement the simplest possible migration logic to make the failing RED tests pass.
 - Focus on creating the necessary `MigrationStrategy` for Hive.
- Key Practices:
 - Implement the `MigrationStrategy` to handle version upgrades and downgrades if necessary.
 - Provide a clear, step-by-step transformation of old data to the new schema within the migration function.
 - Ensure that the migration process is efficient and does not cause data loss or corruption.
- Source Index:
 - [Hive CE Migration Examples](https://docs.hivedb.dev/#/hive_ce/migrations?id=examples) — practical examples of implementing migrations.
- Reuse Notes:
 - Apply when implementing new schema changes for any Hive box.

#### BLUE Guidance
- Summary:
 - Refactor the migration helpers to be robust, reusable, and clearly documented.
 - Ensure the migration strategy is easily extensible for future schema changes.
- Key Practices:
 - Centralize migration logic and version management.
 - Add comments and documentation to explain complex migration steps.
 - Verify that the migration process is performant for large datasets.
- Source Index:
 - [Effective Dart: Design](https://dart.dev/effective-dart/design) — guidelines for creating well-designed APIs.
 - [Refactoring.Guru](https://refactoring.guru/) — general refactoring patterns.
- Reuse Notes:
 - Apply during future refactors of storage infrastructure or when introducing new data models.

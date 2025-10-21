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

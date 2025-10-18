# Dependency Change Log

Record every dependency change with a brief justification. One entry per logical change. Keep entries concise and link to the related task/PR.

Template

- Date: YYYY-MM-DD
- Changed by: @handle
- Affected pubspec: <root|packages/<name>/pubspec.yaml>
- Packages: name@constraint[, ...]
- Why: <short justification; reference roadmap task/issue>
- Scope/usage: <where used>
- PR/Issue: <link>

Entries

- Date: 2025-09-30
- Changed by: @codex
- Affected pubspec: packages/infrastructure/pubspec.yaml
- Packages: riverpod@^2.5.1, test@^1.25.2
- Why: scaffold infrastructure service providers and add unit tests
- Scope/usage: Hive/secure storage/logging providers with in-memory stubs
- PR/Issue: n/a

- Date: 2025-09-30
- Changed by: @codex
- Affected pubspec: packages/core/pubspec.yaml
- Packages: test@^1.25.2
- Why: enable core primitives TDD as part of workspace restructure tasks
- Scope/usage: unit tests validating Result, EntityId, and domain events
- PR/Issue: n/a

- Date: 2025-10-01
- Changed by: @codex
- Affected pubspec: features/ingest/pubspec.yaml
- Packages: collection@^1.18.0, meta@^1.11.0
- Why: support immutable equality/map comparison and leverage meta annotations in CaptureItem domain entity
- Scope/usage: CaptureItem metadata comparison, @immutable annotations for domain types
- PR/Issue: n/a

- Date: 2025-10-01
- Changed by: @codex
- Affected pubspec: packages/infrastructure/pubspec.yaml
- Packages: collection@^1.18.0, meta@^1.11.0
- Why: notification facade immutability and deep equality helpers
- Scope/usage: NotificationRequest payload handling and annotations
- PR/Issue: n/a

- Date: 2025-10-02
- Changed by: @codex
- Affected pubspec: app/pubspec.yaml
- Packages: flutter_riverpod@^3.0.1
- Why: enable ProviderScope bootstrapping for global overrides (Milestone 4)
- Scope/usage: Root app widget wraps MaterialApp with ProviderScope
- PR/Issue: n/a

- Date: 2025-10-18
- Changed by: @codex
- Affected pubspec: packages/infrastructure/pubspec.yaml
- Packages: hive_ce@^2.14.0, hive_ce_flutter@^2.3.2, path_provider@^2.1.5
- Why: implement real Hive CE storage to replace InMemoryHiveInitializer (Green Phase TDD)
- Scope/usage: RealHiveInitializer with persistent encrypted boxes for capture items
- PR/Issue: TDD Green Phase - Complete data persistence implementation

- Date:
- Changed by:
- Affected pubspec:
- Packages:
- Why:
- Scope/usage:
- PR/Issue:

# CascadeFlow Dependency Matrix

Project target: Dart `>=3.9.2 <4.0.0`, Flutter `>=3.24.0`. The documentation recommends a lean set of packages per layer; the table below captures the latest pub.dev data (7 Oct 2025) and the decision after evaluating viable alternatives.

## Domain Layer

| Package | Latest Version | SDK Constraint | Flutter Constraint | Alternatives Reviewed | Decision |
| --- | --- | --- | --- | --- | --- |
| `fpdart` | `1.1.1` | `>=3.0.0 <4.0.0` | n/a | `oxidized` (6.2.0, smaller ecosystem) | Keep `fpdart`; Flutter Favorite with richer APIs and higher adoption (1k+ likes).

## Data Layer

| Package (Doc) | Latest Version | Constraint Notes | Alternatives Reviewed | Recommendation |
| --- | --- | --- | --- | --- |
| `hive` | `2.2.3` | SDK `<3.0.0` – incompatible with Dart 3.9 | `hive_ce`, `drift`, `sembast` | Replace with `hive_ce 2.14.0` (SDK `^3.4.0`) for Dart 3 support while keeping Hive APIs.
| `hive_flutter` | `1.1.0` | SDK `<3.0.0`; blocks Flutter 3.x apps | `hive_ce_flutter`, `isar_flutter_libs` | Replace with `hive_ce_flutter 2.3.2` (Flutter `>=3.27.0`). Requires bumping min Flutter SDK from 3.24 to 3.27.
| `path_provider` | `2.1.5` | Flutter `>=3.22.0` | `file_selector` | Keep `path_provider`; still Flutter Favorite with 4M+ monthly downloads.

_Notes_: `sembast` (3.8.5+1) remains an escape hatch if we must stay on Flutter 3.24 without upgrading, but it lacks Hive’s binary adapter performance.

## Infrastructure Layer

| Package (Doc) | Latest Version | Constraint Notes | Alternatives Reviewed | Recommendation |
| --- | --- | --- | --- | --- |
| `get_it` | `8.2.0` | Adds second DI container alongside Riverpod | `riverpod_annotation`, `riverpod_generator` | Drop `get_it`; rely on Riverpod. Adopt `riverpod_annotation 3.0.1` + `riverpod_generator 3.0.1` (dev) with `build_runner 2.8.0` for codegen.
| `injectable` | `2.5.2` | Overlaps with Riverpod DI | `riverpod_annotation` | Same as above – consolidate on Riverpod’s generator-based DI.
| `logger` | `2.6.1` | SDK `>=2.17.0 <4.0.0` | `talker_flutter` (UI tooling), `dart_dev_logger` | Keep `logger`; simple, lightweight, zero runtime dependencies.
| `flutter_secure_storage` | `9.2.4` | Flutter `>=2.0.0` | `awesome_secure_storage`, `cryptography` | Keep `flutter_secure_storage`; continues to be the most widely supported cross-platform secure KV store.
| `riverpod` | `3.0.1` | SDK `^3.7.0` | n/a | Keep; aligns with Riverpod-first architecture.

## Presentation Layer

| Package (Doc) | Latest Version | Flutter Constraint | Alternatives Reviewed | Recommendation |
| --- | --- | --- | --- | --- |
| `flutter_riverpod` | `3.0.1` | `>=3.0.0` | `hooks_riverpod` | Keep; matches chosen state management strategy.
| `go_router` | `16.2.4` | `>=3.29.0` | `auto_route 10.1.2`, `beamer 1.7.0` | Pin to `go_router 14.2.3` (Flutter `>=3.16.0`) until the project upgrades to Flutter 3.29+. Still official and well-supported.
| `intl` | `0.20.2` | SDK `^3.3.0` | `slang`, `timeago` | Keep; canonical i18n library with 5k+ likes.
| `flex_color_scheme` | `8.3.0` | `>=3.35.0` | `material_color_utilities`, `theme_tailor` | Use `flex_color_scheme 8.0.2` (Flutter `>=3.24.0`) to stay within current toolchain while retaining Material 3 helpers.
| `flutter_local_notifications` | `19.4.2` | `>=3.22.0` | `awesome_notifications` | Keep; still the most feature-complete, with higher platform coverage.

## Summary

- Immediate upgrades: switch to `hive_ce`/`hive_ce_flutter` and add Riverpod codegen tooling (`riverpod_annotation`, `riverpod_generator`, `build_runner`).
- Version pins: `go_router 14.2.3` and `flex_color_scheme 8.0.2` keep us compatible with Flutter 3.24 while staying close to upstream.
- Next review: revisit Hive CE vs upstream Hive once Hive 4.0.0 lands with stable Dart 3 constraints, and reassess `go_router`/`flex_color_scheme` after upgrading Flutter.

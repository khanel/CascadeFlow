# Dependency Policy

This project adds dependencies only when there is a concrete, immediate need in the codebase. Each addition is small, justified, and verified before merging. The goal is to keep the dependency graph lean, understandable, and maintainable.

## Principles

1. Just‑in‑time: add a package only when a task requires it.
2. Small diffs: add one logical group at a time (per feature/phase).
3. Justification: document the why, where, and scope in the dependency log.
4. Prefer core/first‑party APIs when feasible.
5. Minimize transitive bloat: evaluate alternatives and check popularity/maintenance.
6. Constrain versions reasonably; avoid overly broad ranges.
7. Remove unused dependencies promptly.

## Workflow (Step‑by‑Step)

1. Identify need
   - Reference the roadmap task or issue that requires the dependency.
   - Briefly evaluate alternatives (including standard library or existing packages).

2. Propose
   - Edit `pubspec.yaml` (or a package’s `pubspec.yaml`) with the minimal required package(s).
   - Update `docs/dependency-log.md` with: package, reason, scope, owner, and links.

3. Validate locally
   - Run `flutter pub get`.
   - Run `flutter pub outdated` and note any surprising constraints.
   - Run analysis and tests: `dart analyze && flutter test`.

4. Review
   - In the PR description, include the dependency summary and why alternatives were not chosen.
   - Ensure the change is limited to the smallest surface needed.

5. Maintain
   - Periodically run `flutter pub outdated` and review major updates consciously.
   - Remove or downgrade if the package proves unnecessary or heavy.

## Common Packages by Layer (Add When Needed)

- Domain: `fpdart`
- Data: `hive_ce`, `hive_ce_flutter`, `path_provider`
- Infrastructure: `riverpod`, `riverpod_annotation`, `riverpod_generator`, `logger`, `flutter_secure_storage`
- Presentation: `flutter_riverpod`, `go_router` (pin to `14.2.3` until Flutter `>=3.29`), `intl`, `flex_color_scheme` (use `8.0.2` with Flutter `3.24`)

When adopting generated providers, include `build_runner` in `dev_dependencies` and run `dart run build_runner watch --delete-conflicting-outputs` within the affected package.

Note: These are suggestions aligned with the roadmap; do not add until the corresponding tasks require them.

# Contributing to CascadeFlow

Thanks for investing time in CascadeFlow! This guide walks you through the contributor workflow, coding conventions, and quality checks so that every pull request lands smoothly.

## Quick Start Checklist
1. Install Flutter 3.24+ (Dart 3.5+) and ensure `melos` is available (`dart pub global activate melos`).
2. Clone the repository and run `melos bootstrap` from the repo root.
3. Verify the workspace with `melos run analyze` and `melos test` (or the package-level equivalents).
4. Create a feature branch with a descriptive name (e.g., `feature/ingest-quick-entry`).
5. Follow the TDD commit cadence (red → green → refactor) described below.
6. Update documentation and the progress tracker when you complete roadmap items.
7. Push your branch and open a pull request using Conventional Commit messages.

## Repository Layout Recap
CascadeFlow is a Melos-managed monorepo organised by feature slices:
- `app/` – Flutter runner (ProviderScope, theming, routing, bootstrapping).
- `core/` – Shared primitives (`Failure`, `Result`, value objects, domain events).
- `infrastructure/` – Cross-cutting services (Hive init, secure storage, notifications, logging) exposed via Riverpod providers.
- `features/<slice>/` – Vertical feature packages (domain, data, presentation subfolders) for pillars such as `ingest`, `goals`, `prioritize`, etc.

When in doubt, keep logic inside the feature package that owns it. Touch `core/` only for universal primitives and `infrastructure/` only for cross-feature services.

## Development Workflow
### 1. Plan the Work
- Align with the roadmap (`docs/project/roadmap.md`) and progress tracker (`docs/project/progress.md`).
- If the task is not yet captured, add an entry to the tracker before starting.
- For larger pieces (e.g., new feature slices), create a lightweight plan document under `docs/project/`.

### 2. Test-Driven Development (TDD)
CascadeFlow uses a strict TDD cadence:
1. **Red** – add failing tests only; no production code yet.
2. **Green** – implement the minimal code required to make tests pass.
3. **Refactor** – clean up code (naming, structure, performance) while keeping the suite green.

Each phase should be committed separately (see the commit flow section). Run tests locally during each phase.

### 3. Coding Standards
- Prefer small, composable functions and immutable data structures.
- Follow the lint set in `analysis_options.yaml` (Very Good Analysis).
- Keep `core/` tiny; domain/business rules belong in feature packages.
- Use Riverpod for dependency injection and state. Do not introduce alternate DI frameworks.

### 4. Dependency Policy
- Only add dependencies when a roadmap task requires them.
- Record every addition/update/removal in `docs/development/dependency-log.md` (use the provided template).
- Keep version constraints as tight as practical and prefer well-maintained packages.
- Remove unused dependencies promptly.

### 5. Testing
- Unit tests live alongside packages (e.g., `packages/core/test`, `features/<slice>/domain/test`).
- Use `melos test` to run the whole suite, or `dart test`/`flutter test` inside a package for faster feedback.
- For Hive-dependent tests, prefer temp directories and fakes for secure storage.
- Aim to add widget/integration tests when UI or cross-slice behaviour is introduced.

### 6. Documentation
- Update relevant docs (architecture, progress, feature plans) as part of your change.
- Document new configuration or scripts in `docs/development/*`.
- When completing roadmap items, tick them in `docs/project/progress.md` and note the accomplishment in the status snapshot if appropriate.

## Commit & PR Guidelines
### Conventional Commits + TDD Cadence
- Use [Conventional Commits](https://www.conventionalcommits.org/) (see `docs/development/COMMIT_CONVENTION.md`).
- For TDD work, enforce the three-commit stack: `test` (red), `feat`/`fix` (green), `refactor` (refinement). Additional commits (e.g., `docs`, `chore`) are fine when scoped separately.
- Subject lines stay under 50 characters; favour the imperative voice ("add", "fix").

### Typical Commit Types
- `feat` – new functionality for end users (feature slice code, UI)
- `fix` – bug fixes
- `refactor` – internal improvements without behavioural change
- `test` – add or update tests only
- `docs` – documentation and guides
- `chore` – tooling, config, or other maintenance tasks

### Pull Request Checklist
- [ ] Branch is rebased onto `main`.
- [ ] All tests pass locally (`melos test` or package-specific command).
- [ ] Static analysis passes (`melos run analyze`).
- [ ] Roadmap/progress docs updated if applicable.
- [ ] Dependency log updated for any dependency changes.
- [ ] Screenshots or GIFs included for notable UI updates (optional but encouraged).
- [ ] Description explains what/why, references issues, and highlights follow-up work.

### Code Review Expectations
- Be receptive to feedback and iterate quickly.
- Respond to every comment—either apply the suggestion or explain trade-offs.
- Keep pull requests scoped; large features can be split into incremental PRs (start with the domain layer, then data, then presentation).

## Running Melos Commands
From the repo root:
- `melos bootstrap` – install/update dependencies for all packages.
- `melos run analyze` – run static analysis across the workspace.
- `melos test` – run every test target (unit/widget/integration).
- `melos run <script>` – execute custom scripts defined in `melos.yaml` (add new scripts as needed for tooling).

## Issue Reporting & Feature Requests
- Open GitHub issues with a clear summary, reproduction steps (if a bug), and any relevant logs/screenshots.
- Tag issues with applicable labels (e.g., `feature`, `bug`, `documentation`, `good-first-issue`).
- For roadmap-aligned features, link to the corresponding milestone section.

## Community Standards
- Be respectful and inclusive. Assume good intent and provide constructive feedback.
- Mentorship matters—include context and references when reviewing or suggesting changes.
- Follow the MIT licence and credit upstream sources when porting ideas/code.

Happy building! If you have questions, start a discussion or open a draft PR so we can collaborate early.

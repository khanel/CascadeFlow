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

### Topic: Flutter Keyboard Shortcuts for Text Input Submission
- Feature / Area: Ingest › Presentation Layer › CaptureQuickAddSheet
- Last Updated: 2025-10-27
- References:
  - Cite this entry in phase notes as "researchIndex.md › Flutter Keyboard Shortcuts for Text Input Submission"

#### RED Guidance
- Summary:
  - Focus tests on verifying that keyboard shortcuts trigger the expected actions (e.g., Ctrl+Enter submits, Escape clears) without relying on UI interactions.
  - Plan for integration with existing TextField onSubmitted behavior to avoid conflicts.
- Key Practices:
  - Use widget tests with simulateKeyDownEvent to trigger shortcuts and assert state changes.
  - Test one shortcut at a time to isolate behavior and ensure clear failure messages.
  - Mock the controller provider to verify shortcut-triggered submissions.
- Source Index:
  - [Add Keyboard Shortcuts to Your Flutter App (No Plugins Needed)](https://dartfoundry.com/add-keyboard-shortcuts-to-your-flutter-app-no-plugins-needed/) — Comprehensive guide on Shortcuts, Actions, and Focus widgets for implementing keyboard shortcuts.
  - [User input & accessibility - Flutter Documentation](https://docs.flutter.dev/ui/adaptive-responsive/input) — Official docs on Shortcuts widget for applying keyboard shortcuts to widget trees.
  - [How to handle keyboard shortcuts - flutter - Stack Overflow](https://stackoverflow.com/questions/61960260/how-to-handle-keyboard-shortcuts) — Community examples of handling Ctrl+I and similar shortcuts in Flutter web apps.
- Reuse Notes:
  - Revisit when adding more shortcuts or when implementing shortcuts in other UI components; otherwise reuse for similar text input shortcut implementations.

#### GREEN Guidance
- Summary:
  - Implement shortcuts using Shortcuts widget wrapping the sheet, with Actions for handling intents, and ensure Focus is properly managed.
  - Keep implementation minimal to pass tests, avoiding over-engineering.
- Key Practices:
  - Wrap the sheet in Shortcuts with LogicalKeySet for Ctrl+Enter and Escape.
  - Use CallbackAction to trigger submission or clearing on shortcut activation.
  - Ensure shortcuts don't interfere with existing TextField behavior.
- Source Index:
  - [Add Keyboard Shortcuts to Your Flutter App (No Plugins Needed)](https://dartfoundry.com/add-keyboard-shortcuts-to-your-flutter-app-no-plugins-needed/) — Step-by-step example of wiring Shortcuts, Actions, and Focus.
  - [Easy Keyboard Shortcuts in Flutter Desktop Apps](https://medium.com/@pmutisya/easy-keyboard-shortcuts-in-flutter-desktop-apps-498862b56b17) — Minimal boilerplate approach for adding shortcuts with descriptive text.
  - [Handling user input - Flutter Documentation](https://docs.flutter.dev/get-started/fundamentals/user-input) — Details on TextField onSubmitted and keyboard event handling.
- Reuse Notes:
  - Apply when implementing shortcuts in other forms or dialogs; guidance applies to Flutter's built-in shortcut system.

#### BLUE Guidance
- Summary:
  - Refactor shortcut implementation for clarity, remove duplication, and ensure consistent code style while preserving behavior.
  - Update tests if needed for better readability and coverage.
- Key Practices:
  - Extract shortcut definitions into constants for maintainability.
  - Ensure Actions are properly scoped and don't leak focus.
  - Run tests after each change to maintain passing state.
- Source Index:
  - [Effective Dart: Design](https://dart.dev/effective-dart/design) — Guidelines for intent-based architecture and API design in shortcut implementations.
  - [Refactoring.Guru](https://refactoring.guru/refactoring/what-is-refactoring) — General refactoring principles for improving code without changing behavior.
- Reuse Notes:
  - Use during future refactors of input handling or when adding accessibility features; remove if shortcuts are removed from the feature.

### Topic: Flutter Voice Capture Implementation for Text Input
- Feature / Area: Ingest › Presentation Layer › CaptureQuickAddSheet
- Last Updated: 2025-10-27
- References:
  - Cite this entry in phase notes as "researchIndex.md › Flutter Voice Capture Implementation for Text Input"

#### RED Guidance
- Summary:
  - Write failing tests that verify voice capture button triggers speech recognition and appends transcribed text to the input field.
  - Focus on testing the integration with speech_to_text package, including permission handling and error states.
- Key Practices:
  - Use widget tests to simulate button tap and mock speech recognition results.
  - Test permission denied scenarios and ensure UI reflects listening state.
  - Assert that transcribed text is appended to existing content without overwriting.
- Source Index:
  - [speech_to_text | Flutter package - Pub.dev](https://pub.dev/packages/speech_to_text) — Official package documentation with initialization and listening examples.
  - [Flutter Speech To Text Tutorial | Voice Recognition App iOS & Android](https://www.youtube.com/watch?v=W4G0v_lu7IE) — Step-by-step tutorial for setting up speech recognition.
  - [Implementing Speech-to-Text and Voice Command Recognition in Flutter](https://geekyants.com/en-us/blog/implementing-speech-to-text-and-voice-command-recognition-in-flutter-enhancing-user-interaction) — Comprehensive guide on integrating speech-to-text for user interaction.
- Reuse Notes:
  - Revisit when implementing voice features in other parts of the app or when upgrading speech_to_text package.

#### GREEN Guidance
- Summary:
  - Implement minimal voice capture using speech_to_text package to append transcribed text to the input field.
  - Handle basic permission requests and listening states.
- Key Practices:
  - Initialize SpeechToText in initState and request permissions.
  - On button press, start listening and append results to the text controller.
  - Show visual feedback during listening (e.g., change button icon).
- Source Index:
  - [speech_to_text | Flutter package - Pub.dev](https://pub.dev/packages/speech_to_text) — Code examples for initialization and listening.
  - [Building a Speech-to-Text Input Using Flutter and BLoC](https://blog.nonstopio.com/building-a-speech-to-text-input-using-flutter-and-bloc-67109cca367c) — Example of integrating speech-to-text with state management.
  - [Flutter Speech To Text - Medium](https://medium.com/@ahmad.hamoush.785/flutter-speech-to-text-8fc4daa59c8c) — Tutorial on continuous listening and result handling.
- Reuse Notes:
  - Apply when adding voice input to other text fields; guidance covers basic speech-to-text integration.

#### BLUE Guidance
- Summary:
  - Refactor voice capture implementation for better error handling, accessibility, and code organization.
  - Ensure consistent styling and remove any duplication.
- Key Practices:
  - Add proper error handling for permission denials and speech recognition failures.
  - Improve accessibility with tooltips and screen reader support.
  - Extract voice capture logic into a separate controller or mixin if needed.
- Source Index:
  - [Effective Dart: Design](https://dart.dev/effective-dart/design) — Guidelines for clean API design in voice features.
  - [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility) — Best practices for accessible voice interfaces.
  - [Refactoring.Guru](https://refactoring.guru/refactoring/what-is-refactoring) — Principles for improving code structure without changing behavior.
- Reuse Notes:
  - Use during future refactors of voice input features or when adding advanced speech processing.

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

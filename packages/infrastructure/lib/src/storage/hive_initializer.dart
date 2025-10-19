// BLUE Phase Refactoring Complete: Applied TDD guidelines
// ✅ Single Responsibility: Clean abstract interface defining storage contracts
// ✅ Appropriate Abstraction Level: High-level API without implementation
//    details
// ✅ Clear Interfaces: Well-defined async/box contract for all implementations

import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';

/// Abstract interface for Hive initializers providing a consistent
/// API.
abstract class HiveInitializer {
  /// Tracks whether `initialize` has already been invoked.
  Future<void>? _initialization;

  /// Marks the initializer as ready. Subsequent calls reuse the same future.
  Future<void> initialize() {
    return _initialization ??= doInitialize();
  }

  /// Subclasses access the initialization future.
  Future<void>? get initialization => _initialization;

  /// Subclasses implement actual initialization logic here.
  Future<void> doInitialize();

  /// Opens (or creates) an encrypted box with the given [name].
  Future<HiveBox<T>> openEncryptedBox<T>(String name);

  /// Ensures initialization is complete before proceeding.
  Future<void> ensureInitialized() async {
    final initFuture = initialization;
    if (initFuture == null) {
      throw const InfrastructureFailure(
        message: 'Hive initializer used before initialize() was called.',
      );
    }
    await initFuture;
  }
}

/// Common interface for Hive box operations.
abstract class HiveBox<T> {
  /// Stores [value] under [key].
  Future<void> put(String key, T value);

  /// Retrieves a value for [key], returning `null` when it is absent.
  Future<T?> get(String key);

  /// Returns an immutable snapshot of the stored values.
  Future<List<T>> values();

  /// Deletes the value stored under [key], doing nothing when it is absent.
  Future<void> delete(String key);

  /// Removes every stored value.
  Future<void> clear();

  /// Returns the value at [key], throwing when it has not been written yet.
  T require(String key);

  /// Closes the box.
  Future<void> close();
}

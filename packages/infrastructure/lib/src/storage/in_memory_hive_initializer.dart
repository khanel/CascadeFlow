import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/storage.dart';

// BLUE Phase Refactoring Complete: Applied TDD guidelines
// ✅ Eliminated duplicate initialization checking logic
// ✅ Improved single responsibility and error handling
// ✅ Renamed method for clarity (Future wrapper removal)

/// In-memory stub used to simulate Hive initialisation during local testing.
class InMemoryHiveInitializer extends HiveInitializer {
  /// Lazily created boxes keyed by their Hive name.
  final Map<String, InMemoryHiveBox<dynamic>> _boxes =
      <String, InMemoryHiveBox<dynamic>>{};

  @override
  Future<void> doInitialize() {
    return Future<void>.value();
  }

  /// Ensures initialization is complete before proceeding.
  Future<void> _ensureInitialized() async {
    final initFuture = initialization;
    if (initFuture == null) {
      throw const InfrastructureFailure(
        message: 'Hive initializer used before initialize() was called.',
      );
    }
    await initFuture;
  }

  @override
  /// Opens (or creates) an in-memory encrypted box with the given [name].
  Future<HiveBox<T>> openEncryptedBox<T>(String name) async {
    await _ensureInitialized();
    final existing = _boxes[name] as InMemoryHiveBox<T>?;
    if (existing != null) {
      return existing;
    }

    final box = InMemoryHiveBox<T>(name: name);
    _boxes[name] = box as InMemoryHiveBox<dynamic>;
    return box;
  }
}

/// Minimal box abstraction that mimics the Hive API relied upon by tests.
class InMemoryHiveBox<T> implements HiveBox<T> {
  /// Creates an in-memory box identified by [name].
  InMemoryHiveBox({required this.name});

  /// Name of the backing box.
  final String name;

  final Map<String, T> _items = <String, T>{};

  @override
  /// Stores [value] under [key].
  Future<void> put(String key, T value) {
    _items[key] = value;
    return Future<void>.value();
  }

  @override
  /// Retrieves a value for [key], returning `null` when it is absent.
  Future<T?> get(String key) {
    return Future<T?>.value(_items[key]);
  }

  @override
  /// Returns an immutable snapshot of the stored values.
  Future<List<T>> values() {
    return Future<List<T>>.value(List.unmodifiable(_items.values));
  }

  @override
  /// Deletes the value stored under [key], doing nothing when it is absent.
  Future<void> delete(String key) {
    _items.remove(key);
    return Future<void>.value();
  }

  @override
  /// Removes every stored value.
  Future<void> clear() {
    _items.clear();
    return Future<void>.value();
  }

  @override
  /// Returns the value at [key], throwing when it has not been written yet.
  T require(String key) {
    final value = _items[key];
    if (value == null) {
      throw InfrastructureFailure(
        message: 'Key "$key" missing from box "$name".',
      );
    }
    return value;
  }

  @override
  Future<void> close() {
    return Future.value();
  }
}

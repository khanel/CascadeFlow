import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';

/// In-memory stub used to simulate Hive initialisation during local testing.
class InMemoryHiveInitializer {
  /// Tracks whether `initialize` has already been invoked.
  Future<void>? _initialization;

  /// Lazily created boxes keyed by their Hive name.
  final Map<String, InMemoryHiveBox<dynamic>> _boxes =
      <String, InMemoryHiveBox<dynamic>>{};

  /// Marks the initializer as ready. Subsequent calls reuse the same future.
  Future<void> initialize() {
    return _initialization ??= Future<void>.value();
  }

  /// Opens (or creates) an in-memory encrypted box with the given [name].
  Future<InMemoryHiveBox<T>> openEncryptedBox<T>(String name) async {
    final initialization = _initialization;
    if (initialization == null) {
      throw const InfrastructureFailure(
        message: 'Hive initializer used before initialize() was called.',
      );
    }
    await initialization;

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
class InMemoryHiveBox<T> {
  /// Creates an in-memory box identified by [name].
  InMemoryHiveBox({required this.name});

  /// Name of the backing box.
  final String name;

  final Map<String, T> _items = <String, T>{};

  /// Stores [value] under [key].
  Future<void> put(String key, T value) {
    _items[key] = value;
    return Future<void>.value();
  }

  /// Retrieves a value for [key], returning `null` when it is absent.
  Future<T?> get(String key) {
    return Future<T?>.value(_items[key]);
  }

  /// Returns an immutable snapshot of the stored values.
  Future<List<T>> values() {
    return Future<List<T>>.value(List.unmodifiable(_items.values));
  }

  /// Deletes the value stored under [key], doing nothing when it is absent.
  Future<void> delete(String key) {
    _items.remove(key);
    return Future<void>.value();
  }

  /// Removes every stored value.
  Future<void> clear() {
    _items.clear();
    return Future<void>.value();
  }

  /// Returns the value at [key], throwing when it has not been written yet.
  T require(String key) {
    final value = _items[key];
    if (value == null && !_items.containsKey(key)) {
      throw InfrastructureFailure(
        message: 'Key "$key" missing from box "$name".',
      );
    }
    return value as T;
  }
}

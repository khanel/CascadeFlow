import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';

class InMemoryHiveInitializer {
  Future<void>? _initialization;
  final Map<String, _InMemoryHiveBox<dynamic>> _boxes =
      <String, _InMemoryHiveBox<dynamic>>{};

  Future<void> initialize() {
    return _initialization ??= Future<void>.value();
  }

  Future<_InMemoryHiveBox<T>> openEncryptedBox<T>(String name) async {
    final initialization = _initialization;
    if (initialization == null) {
      throw const InfrastructureFailure(
        message: 'Hive initializer used before initialize() was called.',
      );
    }
    await initialization;

    final existing = _boxes[name] as _InMemoryHiveBox<T>?;
    if (existing != null) {
      return existing;
    }

    final box = _InMemoryHiveBox<T>(name: name);
    _boxes[name] = box as _InMemoryHiveBox<dynamic>;
    return box;
  }
}

class _InMemoryHiveBox<T> {
  _InMemoryHiveBox({required this.name});

  final String name;
  final Map<String, T> _items = <String, T>{};

  Future<void> put(String key, T value) {
    _items[key] = value;
    return Future<void>.value();
  }

  Future<T?> get(String key) {
    return Future<T?>.value(_items[key]);
  }

  Future<List<T>> values() {
    return Future<List<T>>.value(List.unmodifiable(_items.values));
  }

  Future<void> clear() {
    _items.clear();
    return Future<void>.value();
  }

  T require(String key) {
    if (!_items.containsKey(key)) {
      throw InfrastructureFailure(
        message: 'Key "$key" missing from box "$name".',
      );
    }
    return _items[key] as T;
  }
}

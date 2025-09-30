import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';

class InMemoryHiveInitializer {
  bool _initialized = false;
  final Map<String, InMemoryHiveBox<dynamic>> _boxes = {};

  Future<void> initialize() async {
    _initialized = true;
  }

  Future<InMemoryHiveBox<T>> openEncryptedBox<T>(String name) async {
    if (!_initialized) {
      throw const InfrastructureFailure(
        message: 'Hive initializer used before initialize() was called.',
      );
    }

    final existing = _boxes[name] as InMemoryHiveBox<T>?;
    if (existing != null) {
      return existing;
    }

    final box = InMemoryHiveBox<T>(name: name);
    _boxes[name] = box;
    return box;
  }
}

class InMemoryHiveBox<T> {
  InMemoryHiveBox({required this.name});

  final String name;
  final Map<String, T> _items = {};

  Future<void> put(String key, T value) async {
    _items[key] = value;
  }

  Future<T?> get(String key) async {
    return _items[key];
  }

  Future<List<T>> values() async {
    return List.unmodifiable(_items.values);
  }

  Future<void> clear() async {
    _items.clear();
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

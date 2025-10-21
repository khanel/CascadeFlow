import 'dart:async';

import 'package:cascade_flow_infrastructure/src/storage/secure_storage.dart';

/// Simple in-memory stand-in for secure storage used during tests.
class InMemorySecureStorage implements SecureStorage {
  final Map<String, String> _storage = <String, String>{};

  /// Persists [value] under [key]. Passing `null` removes the key.
  @override
  Future<void> write({required String key, required String? value}) {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
    return Future<void>.value();
  }

  /// Reads the stored value for [key], returning `null` when absent.
  @override
  Future<String?> read({required String key}) {
    return Future<String?>.value(_storage[key]);
  }

  /// Deletes the stored value for [key].
  @override
  Future<void> delete({required String key}) {
    _storage.remove(key);
    return Future<void>.value();
  }

  /// Clears every stored key/value pair.
  @override
  Future<void> clear() {
    _storage.clear();
    return Future<void>.value();
  }
}

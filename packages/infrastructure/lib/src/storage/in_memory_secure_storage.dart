import 'dart:async';

/// Simple in-memory stand-in for secure storage used during tests.
class InMemorySecureStorage {
  final Map<String, String> _storage = <String, String>{};

  /// Persists [value] under [key]. Passing `null` removes the key.
  Future<void> write({required String key, required String? value}) {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
    return Future<void>.value();
  }

  /// Reads the stored value for [key], returning `null` when absent.
  Future<String?> read({required String key}) {
    return Future<String?>.value(_storage[key]);
  }

  /// Deletes the stored value for [key].
  Future<void> delete({required String key}) {
    _storage.remove(key);
    return Future<void>.value();
  }

  /// Clears every stored key/value pair.
  Future<void> clear() {
    _storage.clear();
    return Future<void>.value();
  }
}

import 'dart:async';

class InMemorySecureStorage {
  final Map<String, String> _storage = {};

  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _storage.remove(key);
      return;
    }
    _storage[key] = value;
  }

  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  Future<void> clear() async {
    _storage.clear();
  }
}

import 'dart:async';

class InMemorySecureStorage {
  final Map<String, String> _storage = <String, String>{};

  Future<void> write({required String key, required String? value}) {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
    return _complete();
  }

  Future<String?> read({required String key}) {
    return Future<String?>.value(_storage[key]);
  }

  Future<void> delete({required String key}) {
    _storage.remove(key);
    return _complete();
  }

  Future<void> clear() {
    _storage.clear();
    return _complete();
  }

  Future<void> _complete() => Future<void>.value();
}

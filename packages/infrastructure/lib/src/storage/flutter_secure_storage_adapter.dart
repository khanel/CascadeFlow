import 'dart:async';

import 'package:cascade_flow_infrastructure/src/storage/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Adapter that exposes [FlutterSecureStorage] through the [SecureStorage]
/// interface.
class FlutterSecureStorageAdapter implements SecureStorage {
  /// Creates an adapter wrapping [FlutterSecureStorage].
  FlutterSecureStorageAdapter([
    FlutterSecureStorage? secureStorage,
  ]) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> write({required String key, required String? value}) {
    return _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) {
    return _secureStorage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) {
    return _secureStorage.delete(key: key);
  }

  @override
  Future<void> clear() {
    return _secureStorage.deleteAll();
  }
}

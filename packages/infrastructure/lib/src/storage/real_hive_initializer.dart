import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

// REFACTORING COMPLETE: BLUE phase of TDD cycle
// ✅ Eliminated duplicate initialization checking logic
// ✅ Separated concerns (setup, registration, box opening)
// ✅ Improved single responsibility and readability
// ✅ Fixed unnecessary null check and void assignment
// ✅ Fixed unnecessary this qualifier and cascade invocations

/// Real Hive CE initializer for production use with persistent storage.
class RealHiveInitializer extends HiveInitializer {
  /// Creates a real Hive initializer for production use.
  RealHiveInitializer([
    SecureStorage? secureStorage,
  ]) : _secureStorage = secureStorage ?? FlutterSecureStorageAdapter();

  static const _keyStorageKey = 'hive_encryption_key';

  final SecureStorage _secureStorage;

  @override
  Future<void> doInitialize() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocsDir.path);
  }

  @override
  /// Opens (or creates) a real Hive box with the given [name].
  Future<HiveBox<T>> openEncryptedBox<T>(String name) async {
    await ensureInitialized();
    final encryptionKey = await _getOrGenerateEncryptionKey();
    final box = await Hive.openBox<T>(
      name,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    return RealHiveBox<T>._(box);
  }

  Future<Uint8List> _getOrGenerateEncryptionKey() async {
    final existingKey = await _secureStorage.read(key: _keyStorageKey);
    if (existingKey != null) {
      return base64Url.decode(existingKey);
    }
    final newKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _keyStorageKey,
      value: base64Url.encode(newKey),
    );
    return Uint8List.fromList(newKey);
  }

  /// Opens (or creates) an unencrypted Hive box (for testing or non-sensitive
  /// data).
  @visibleForTesting
  Future<RealHiveBox<T>> openBox<T>(String name) async {
    await ensureInitialized();
    final box = await Hive.openBox<T>(name);
    return RealHiveBox<T>._(box);
  }
}

/// Box wrapper that matches the InMemoryHiveBox interface but uses real Hive
/// Box.
class RealHiveBox<T> implements HiveBox<T> {
  RealHiveBox._(this._box);

  final Box<T> _box;

  @override
  /// Stores [value] under [key].
  Future<void> put(String key, T value) async {
    await _box.put(key, value);
  }

  @override
  /// Retrieves a value for [key], returning `null` when it is absent.
  Future<T?> get(String key) => Future.value(_box.get(key));

  @override
  /// Returns an immutable snapshot of the stored values.
  Future<List<T>> values() => Future.value(List.unmodifiable(_box.values));

  @override
  /// Deletes the value stored under [key], doing nothing when it is absent.
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  @override
  /// Removes every stored value.
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  /// Returns the value at [key], throwing when it has not been written yet.
  T require(String key) {
    if (!_box.containsKey(key)) {
      throw InfrastructureFailure(
        message: 'Key "$key" missing from box "${_box.name}".',
      );
    }
    return _box.get(key) as T;
  }

  @override
  Future<void> close() => _box.close();
}

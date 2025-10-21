import 'dart:async';

/// Abstraction over secure storage implementations used by the app.
abstract class SecureStorage {
  /// Persists [value] under [key]. Passing `null` removes the stored value.
  Future<void> write({required String key, required String? value});

  /// Reads the stored value for [key], returning `null` when absent.
  Future<String?> read({required String key});

  /// Removes the stored value associated with [key].
  Future<void> delete({required String key});

  /// Clears the entire secure storage.
  Future<void> clear();
}

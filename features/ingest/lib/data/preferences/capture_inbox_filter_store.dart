import 'dart:convert';

import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_exceptions.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_filter.dart';

/// Persists capture inbox filter selections and presets using secure storage.
class CaptureInboxFilterStore {
  /// Creates a store for persisting inbox filters.
  CaptureInboxFilterStore({required SecureStorage secureStorage})
    : _secureStorage = secureStorage;

  static const String _storageKey = 'captureInboxFilter';
  static const String _presetsStorageKey = 'captureInboxFilterPresets';

  final SecureStorage _secureStorage;

  /// Loads the previously stored filter, returning empty filter when absent.
  Future<CaptureInboxFilter> load() async {
    return _loadWithDefault(
      _storageKey,
      () => CaptureInboxFilter.empty,
      (decoded) => CaptureInboxFilter.fromJson(decoded as Map<String, dynamic>),
    );
  }

  /// Saves the provided [filter] snapshot to storage.
  Future<void> save(CaptureInboxFilter filter) async {
    try {
      final payload = jsonEncode(filter.toJson());
      await _secureStorage.write(
        key: _storageKey,
        value: payload,
      );
    } on Object catch (error) {
      throw FilterStorageException(
        'Failed to save filter to storage',
        error,
      );
    }
  }

  /// Clears any stored filter selection.
  Future<void> clear() {
    return _secureStorage.delete(key: _storageKey);
  }

  /// Loads all saved filter presets.
  Future<List<CaptureFilterPreset>> loadPresets() async {
    return _loadWithDefault(
      _presetsStorageKey,
      () => <CaptureFilterPreset>[],
      (decoded) => (decoded as List<dynamic>)
          .map(
            (json) =>
                CaptureFilterPreset.fromJson(json as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Saves a new or updated filter preset.
  Future<void> savePreset(CaptureFilterPreset preset) async {
    await _modifyPresets(
      'save preset "${preset.name}"',
      (presets) {
        final index = presets.indexWhere((p) => p.name == preset.name);
        if (index >= 0) {
          presets[index] = preset;
        } else {
          presets.add(preset);
        }
      },
    );
  }

  /// Deletes a filter preset by name.
  Future<void> deletePreset(String name) async {
    await _modifyPresets(
      'delete preset "$name"',
      (presets) => presets.removeWhere((p) => p.name == name),
    );
  }

  /// Clears all saved presets.
  Future<void> clearPresets() {
    return _secureStorage.delete(key: _presetsStorageKey);
  }

  /// Generic helper for loading with default fallback on errors.
  Future<T> _loadWithDefault<T>(
    String key,
    T Function() defaultValue,
    T Function(dynamic decoded) fromJson,
  ) async {
    try {
      final raw = await _secureStorage.read(key: key);
      if (raw == null || raw.isEmpty) {
        return defaultValue();
      }
      final decoded = jsonDecode(raw);
      return fromJson(decoded);
    } on Object {
      return defaultValue();
    }
  }

  /// Helper method to modify presets with proper error handling.
  Future<void> _modifyPresets(
    String operation,
    void Function(List<CaptureFilterPreset> presets) modify,
  ) async {
    try {
      final presets = await loadPresets();
      modify(presets);
      final payload = jsonEncode(presets.map((p) => p.toJson()).toList());
      await _secureStorage.write(key: _presetsStorageKey, value: payload);
    } on FilterStorageException {
      rethrow;
    } on Object catch (error) {
      throw FilterPresetException(
        'Failed to $operation',
        error,
      );
    }
  }
}

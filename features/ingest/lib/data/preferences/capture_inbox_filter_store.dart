import 'dart:convert';

import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_filter.dart';

/// Persists capture inbox filter selections and presets using secure storage.
class CaptureInboxFilterStore {
  /// Creates a store that persists inbox filters via the provided storage.
  CaptureInboxFilterStore({required InMemorySecureStorage secureStorage})
    : _secureStorage = secureStorage;

  static const String _storageKey = 'captureInboxFilter';
  static const String _presetsStorageKey = 'captureInboxFilterPresets';

  final InMemorySecureStorage _secureStorage;

  /// Loads the previously stored filter, returning empty filter when absent.
  Future<CaptureInboxFilter> load() async {
    final raw = await _secureStorage.read(key: _storageKey);
    if (raw == null || raw.isEmpty) {
      return CaptureInboxFilter.empty;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return CaptureInboxFilter.fromJson(decoded);
    } on Object {
      // Corrupted storage results fall back to empty filter.
      return CaptureInboxFilter.empty;
    }
  }

  /// Saves the provided [filter] snapshot to storage.
  Future<void> save(CaptureInboxFilter filter) {
    final payload = jsonEncode(filter.toJson());
    return _secureStorage.write(
      key: _storageKey,
      value: payload,
    );
  }

  /// Clears any stored filter selection.
  Future<void> clear() {
    return _secureStorage.delete(key: _storageKey);
  }

  /// Loads all saved filter presets.
  Future<List<CaptureFilterPreset>> loadPresets() async {
    final raw = await _secureStorage.read(key: _presetsStorageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((json) => CaptureFilterPreset.fromJson(json as Map<String, dynamic>))
          .toList();
    } on Object {
      // Corrupted storage results in empty presets list.
      return [];
    }
  }

  /// Saves a new or updated filter preset.
  Future<void> savePreset(CaptureFilterPreset preset) async {
    final presets = await loadPresets();
    final index = presets.indexWhere((p) => p.name == preset.name);
    if (index >= 0) {
      presets[index] = preset;
    } else {
      presets.add(preset);
    }
    final payload = jsonEncode(presets.map((p) => p.toJson()).toList());
    await _secureStorage.write(key: _presetsStorageKey, value: payload);
  }

  /// Deletes a filter preset by name.
  Future<void> deletePreset(String name) async {
    final presets = await loadPresets();
    presets.removeWhere((p) => p.name == name);
    final payload = jsonEncode(presets.map((p) => p.toJson()).toList());
    await _secureStorage.write(key: _presetsStorageKey, value: payload);
  }

  /// Clears all saved presets.
  Future<void> clearPresets() {
    return _secureStorage.delete(key: _presetsStorageKey);
  }
}

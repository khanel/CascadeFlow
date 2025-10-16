import 'dart:convert';

import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_filter.dart';

/// Persists capture inbox filter selections using secure storage.
class CaptureInboxFilterStore {
  /// Creates a store that persists inbox filters via the provided storage.
  CaptureInboxFilterStore({required InMemorySecureStorage secureStorage})
    : _secureStorage = secureStorage;

  static const String _storageKey = 'captureInboxFilter';

  final InMemorySecureStorage _secureStorage;

  /// Loads the previously stored filter, returning empty filter when absent.
  Future<CaptureInboxFilter> load() async {
    final raw = await _secureStorage.read(key: _storageKey);
    if (raw == null || raw.isEmpty) {
      return CaptureInboxFilter.empty;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final sourceName = decoded['source'] as String?;
      final channel = decoded['channel'] as String?;
      return CaptureInboxFilter(
        source: _captureSourceFromName(sourceName),
        channel: channel,
      );
    } on Object {
      // Corrupted storage results fall back to empty filter.
      return CaptureInboxFilter.empty;
    }
  }

  /// Saves the provided [filter] snapshot to storage.
  Future<void> save(CaptureInboxFilter filter) {
    final payload = <String, String?>{
      'source': filter.source?.name,
      'channel': filter.channel,
    };
    return _secureStorage.write(
      key: _storageKey,
      value: jsonEncode(payload),
    );
  }

  /// Clears any stored filter selection.
  Future<void> clear() {
    return _secureStorage.delete(key: _storageKey);
  }

  CaptureSource? _captureSourceFromName(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }
    for (final value in CaptureSource.values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}

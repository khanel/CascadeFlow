/// Constants used throughout the capture inbox feature.
class CaptureInboxConstants {
  /// Storage key for persisting the current filter selection.
  static const String filterStorageKey = 'captureInboxFilter';

  /// Storage key for persisting filter presets.
  static const String presetsStorageKey = 'captureInboxFilterPresets';

  /// Default batch size for inbox pagination.
  static const int defaultBatchSize = 50;
}

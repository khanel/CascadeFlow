/// Custom exceptions for the capture inbox feature.
class CaptureInboxException implements Exception {
  /// Creates an exception with the provided [message].
  const CaptureInboxException(this.message);

  /// Error message describing the exception.
  final String message;

  @override
  String toString() => 'CaptureInboxException: $message';
}

/// Exception thrown when filter storage operations fail.
class FilterStorageException extends CaptureInboxException {
  /// Creates a storage exception with [message] and optional [cause].
  const FilterStorageException(super.message, [this.cause]);

  /// The underlying cause of the storage failure.
  final Object? cause;

  @override
  String toString() =>
      'FilterStorageException: $message'
      '${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Exception thrown when filter preset operations fail.
class FilterPresetException extends CaptureInboxException {
  /// Creates a preset exception with [message] and optional [cause].
  const FilterPresetException(super.message, [this.cause]);

  /// The underlying cause of the preset failure.
  final Object? cause;

  @override
  String toString() =>
      'FilterPresetException: $message'
      '${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Exception thrown when JSON serialization/deserialization fails.
class FilterSerializationException extends CaptureInboxException {
  /// Creates a serialization exception with [message] and optional [cause].
  const FilterSerializationException(super.message, [this.cause]);

  /// The underlying cause of the serialization failure.
  final Object? cause;

  @override
  String toString() =>
      'FilterSerializationException: $message'
      '${cause != null ? ' (caused by: $cause)' : ''}';
}

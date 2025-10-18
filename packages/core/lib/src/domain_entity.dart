// BLUE Phase Refactoring Complete: Applied TDD guidelines
// ✅ Proper Separation of Concerns: Enums and base types moved to core layer
// ✅ No Duplication: Avoids repeating enum definitions across packages
// ✅ Single Responsibility: Clean base definitions without feature-specific
//    logic
// ✅ Clean Architecture: Core primitives available to all features

import 'package:cascade_flow_core/src/failure.dart';
import 'package:meta/meta.dart';

/// Supported sources for captured items.
enum CaptureSource {
  /// Captured from the quick capture UI inside the app.
  quickCapture,

  /// Generated from automations or integrations.
  automation,

  /// Created via voice capture flows.
  voice,

  /// Captured through a share-sheet style intent.
  shareSheet,

  /// Imported from external files or services.
  import,
}

/// Lifecycle state for a captured item.
enum CaptureStatus {
  /// Capture remains in the inbox awaiting processing.
  inbox,

  /// Capture has been processed and filed into a specific context.
  filed,

  /// Capture has been archived or processed.
  archived,
}

/// Contextual information describing how a capture
/// was created.
@immutable
class CaptureContext {
  /// Builds a capture context after validating the channel string.
  factory CaptureContext({
    required CaptureSource source,
    required String channel,
  }) {
    final normalizedChannel = channel.trim();
    if (normalizedChannel.isEmpty) {
      throw const ValidationFailure(
        message: 'CaptureContext channel cannot be blank',
      );
    }
    return CaptureContext._(
      source: source,
      channel: normalizedChannel,
    );
  }

  const CaptureContext._({
    required this.source,
    required this.channel,
  });

  /// Originating source of a capture (e.g. quick capture, voice).
  final CaptureSource source;

  /// Channel identifier used to disambiguate creation mechanisms.
  final String channel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaptureContext &&
        other.source == source &&
        other.channel == channel;
  }

  @override
  int get hashCode => Object.hash(source, channel);

  @override
  String toString() => 'CaptureContext(source: $source, channel: $channel)';
}

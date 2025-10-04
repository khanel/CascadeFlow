import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:meta/meta.dart';

@immutable
class CaptureItem {
  const CaptureItem._({
    required this.id,
    required this.content,
    required this.context,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory CaptureItem.create({
    required EntityId id,
    required String content,
    required CaptureContext context,
    required Timestamp createdAt,
    Timestamp? updatedAt,
    CaptureStatus status = CaptureStatus.inbox,
    Map<String, String>? metadata,
  }) {
    final normalizedContent = _normalizeContent(content);
    final normalizedMetadata = _normalizeMetadata(metadata);
    final resolvedUpdatedAt = updatedAt ?? createdAt;

    return CaptureItem._(
      id: id,
      content: normalizedContent,
      context: context,
      status: status,
      createdAt: createdAt,
      updatedAt: resolvedUpdatedAt,
      metadata: normalizedMetadata,
    );
  }

  final EntityId id;
  final String content;
  final CaptureContext context;
  final CaptureStatus status;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Map<String, String> metadata;

  static const _metadataKeyPattern = r'^[a-z0-9]+(_[a-z0-9]+)*$';

  static String _normalizeContent(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure(
        message: 'CaptureItem content cannot be blank',
      );
    }
    return trimmed;
  }

  static Map<String, String> _normalizeMetadata(
    Map<String, String>? metadata,
  ) {
    if (metadata == null || metadata.isEmpty) {
      return const <String, String>{};
    }

    final pattern = RegExp(_metadataKeyPattern);
    final normalized = <String, String>{};
    metadata.forEach((key, value) {
      final trimmedKey = key.trim();
      if (!pattern.hasMatch(trimmedKey)) {
        throw ValidationFailure(
          message: 'CaptureItem metadata keys must be snake_case: $key',
        );
      }
      normalized[trimmedKey] = value;
    });
    return Map.unmodifiable(normalized);
  }
}

@immutable
class CaptureContext {
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

  final CaptureSource source;
  final String channel;
}

enum CaptureSource {
  quickCapture,
  automation,
  voice,
  shareSheet,
  import,
}

enum CaptureStatus {
  inbox,
  archived,
}

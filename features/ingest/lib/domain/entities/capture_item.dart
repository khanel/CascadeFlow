import 'dart:collection';

import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Domain entity representing a captured inbox entry awaiting processing.
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

  /// Constructs a new capture item while normalising user input.
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
    _guardUpdatedAt(createdAt, resolvedUpdatedAt);

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

  /// Unique identifier for the capture item.
  final EntityId id;

  /// Human-entered or imported text content describing the capture item.
  final String content;

  /// Source context used to provide downstream routing and analytics.
  final CaptureContext context;

  /// Current lifecycle status (e.g. still in inbox, archived).
  final CaptureStatus status;

  /// Timestamp indicating when the capture was created.
  final Timestamp createdAt;

  /// Timestamp indicating when the capture was last modified.
  final Timestamp updatedAt;

  /// Additional metadata persisted alongside the capture entry.
  final Map<String, String> metadata;

  static const _metadataKeyPattern = r'^[a-z0-9]+(_[a-z0-9]+)*$';
  static final RegExp _metadataKeyRegExp = RegExp(_metadataKeyPattern);
  static const MapEquality<String, String> _metadataEquality =
      MapEquality<String, String>();

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

    final normalized = SplayTreeMap<String, String>();
    metadata.forEach((key, value) {
      final trimmedKey = key.trim();
      if (!_metadataKeyRegExp.hasMatch(trimmedKey)) {
        throw ValidationFailure(
          message: 'CaptureItem metadata keys must be snake_case: $key',
        );
      }
      normalized[trimmedKey] = value.trim();
    });
    return UnmodifiableMapView(normalized);
  }

  static void _guardUpdatedAt(Timestamp createdAt, Timestamp updatedAt) {
    if (updatedAt.isBefore(createdAt)) {
      throw const ValidationFailure(
        message: 'CaptureItem updatedAt cannot be before createdAt',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaptureItem &&
        other.id == id &&
        other.content == content &&
        other.context == context &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        _metadataEquality.equals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
    id,
    content,
    context,
    status,
    createdAt,
    updatedAt,
    _metadataEquality.hash(metadata),
  );

  @override
  String toString() {
    return 'CaptureItem(id: $id, status: $status, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  /// Returns a copy of this item with the provided overrides.
  CaptureItem copyWith({
    String? content,
    CaptureContext? context,
    CaptureStatus? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Map<String, String>? metadata,
  }) {
    final nextMetadata = metadata == null
        ? this.metadata
        : Map<String, String>.unmodifiable(metadata);

    final nextUpdatedAt = updatedAt ?? this.updatedAt;
    _guardUpdatedAt(createdAt ?? this.createdAt, nextUpdatedAt);

    return CaptureItem._(
      id: id,
      content: content ?? this.content,
      context: context ?? this.context,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: nextUpdatedAt,
      metadata: nextMetadata,
    );
  }
}

/// Contextual information describing how a capture was created.
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

  /// Capture has been archived or processed.
  archived,
}

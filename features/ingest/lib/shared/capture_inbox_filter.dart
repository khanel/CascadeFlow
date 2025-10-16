import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:meta/meta.dart';

/// Represents a saved filter preset with a name and configuration.
@immutable
class CaptureFilterPreset {
  /// Creates a preset with the given [name] and [filter].
  const CaptureFilterPreset({
    required this.name,
    required this.filter,
    this.createdAt,
  });

  /// Restores a preset from the provided JSON map.
  factory CaptureFilterPreset.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    final filterMap = json['filter'] as Map<String, dynamic>?;
    final createdAtString = json['createdAt'] as String?;

    if (name == null || filterMap == null) {
      throw ArgumentError('Invalid preset JSON: missing name or filter');
    }

    return CaptureFilterPreset(
      name: name,
      filter: CaptureInboxFilter.fromJson(filterMap),
      createdAt: createdAtString != null ? DateTime.parse(createdAtString) : null,
    );
  }

  /// Unique name identifying this preset.
  final String name;

  /// Filter configuration for this preset.
  final CaptureInboxFilter filter;

  /// When this preset was created (optional for backwards compatibility).
  final DateTime? createdAt;

  /// Serializes this preset to a JSON-serializable map.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'filter': filter.toJson(),
    'createdAt': createdAt?.toIso8601String(),
  };

  /// Creates a copy with optional overrides.
  CaptureFilterPreset copyWith({
    String? name,
    CaptureInboxFilter? filter,
    DateTime? createdAt,
  }) {
    return CaptureFilterPreset(
      name: name ?? this.name,
      filter: filter ?? this.filter,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaptureFilterPreset &&
        other.name == name &&
        other.filter == filter &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(name, filter, createdAt);

  @override
  String toString() {
    return 'CaptureFilterPreset(name: $name, filter: $filter, createdAt: $createdAt)';
  }
}

/// Represents user-selected filters for the capture inbox.
@immutable
class CaptureInboxFilter {
  /// Builds a filter with optional [source] and [channel] constraints.
  const CaptureInboxFilter({
    this.source,
    this.channel,
  });

  /// Restores a filter from the provided JSON map.
  factory CaptureInboxFilter.fromJson(Map<String, dynamic> json) {
    final sourceName = json['source'] as String?;
    final channel = json['channel'] as String?;
    return CaptureInboxFilter(
      source: _sourceFromName(sourceName),
      channel: channel,
    );
  }

  /// Shared empty filter instance with no constraints.
  static const CaptureInboxFilter empty = CaptureInboxFilter();

  static const Object _sentinel = Object();

  /// Selected capture source constraint when applied.
  final CaptureSource? source;

  /// Selected capture channel constraint when applied.
  final String? channel;

  /// Returns true when any filter constraint is active.
  bool get isFiltering => source != null || channel != null;

  /// Returns true when [item] satisfies the filter constraints.
  bool matches(CaptureItem item) {
    if (source != null && item.context.source != source) {
      return false;
    }
    if (channel != null && item.context.channel != channel) {
      return false;
    }
    return true;
  }

  /// Returns a copy of this filter with a new [channel] while preserving
  /// the selected source.
  CaptureInboxFilter withChannel(String? value) {
    if (channel == value) {
      return this;
    }
    return copyWith(channel: value);
  }

  /// Applies the current filter to [items], returning the filtered iterable.
  Iterable<CaptureItem> apply(Iterable<CaptureItem> items) {
    return items.where(matches);
  }

  /// Serializes this filter to a JSON-serializable map.
  Map<String, String?> toJson() => <String, String?>{
    'source': source?.name,
    'channel': channel,
  };

  /// Indicates whether the provided [value] matches the active source filter.
  bool isSourceSelected(CaptureSource value) => source == value;

  /// Indicates whether the provided [value] matches the active channel filter.
  bool isChannelSelected(String value) => channel == value;

  /// Creates a copy overriding [source] and/or [channel].
  CaptureInboxFilter copyWith({
    Object? source = _sentinel,
    Object? channel = _sentinel,
  }) {
    final resolvedSource =
        identical(source, _sentinel)
            ? this.source
            : source as CaptureSource?;
    final resolvedChannel =
        identical(channel, _sentinel)
            ? this.channel
            : channel as String?;
    return CaptureInboxFilter(
      source: resolvedSource,
      channel: resolvedChannel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaptureInboxFilter &&
        other.source == source &&
        other.channel == channel;
  }

  @override
  int get hashCode => Object.hash(source, channel);

  @override
  String toString() {
    return 'CaptureInboxFilter(source: $source, channel: $channel)';
  }

  /// Resolves a [CaptureSource] by its serialized [name].
  static CaptureSource? _sourceFromName(String? name) {
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

import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:meta/meta.dart';

/// Represents user-selected filters for the capture inbox.
@immutable
class CaptureInboxFilter {
  /// Builds a filter with optional [source] and [channel] constraints.
  const CaptureInboxFilter({
    this.source,
    this.channel,
  });

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
}

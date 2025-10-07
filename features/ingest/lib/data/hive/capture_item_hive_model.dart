import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';

/// Hive persistence model for `CaptureItem`.
class CaptureItemHiveModel {
  CaptureItemHiveModel({
    required this.id,
    required this.content,
    required this.source,
    required this.channel,
    required this.createdAtMicros,
    required this.updatedAtMicros,
    required this.status,
    required this.metadata,
  });

  final String id;
  final String content;
  final String source;
  final String channel;
  final int createdAtMicros;
  final int updatedAtMicros;
  final String status;
  final Map<String, String> metadata;

  /// Builds a persistence model from the given domain entity.
  factory CaptureItemHiveModel.fromDomain(CaptureItem item) {
    return CaptureItemHiveModel(
      id: item.id.value,
      content: item.content,
      source: item.context.source.name,
      channel: item.context.channel,
      createdAtMicros: item.createdAt.value.microsecondsSinceEpoch,
      updatedAtMicros: item.updatedAt.value.microsecondsSinceEpoch,
      status: item.status.name,
      metadata: Map<String, String>.from(item.metadata),
    );
  }

  /// Converts this Hive model back into a domain entity.
  CaptureItem toDomain() {
    final createdAt = Timestamp(
      DateTime.fromMicrosecondsSinceEpoch(createdAtMicros, isUtc: true),
    );
    final updatedAt = Timestamp(
      DateTime.fromMicrosecondsSinceEpoch(updatedAtMicros, isUtc: true),
    );
    final resolvedSource = CaptureSource.values.firstWhere(
      (value) => value.name == source,
      orElse: () => CaptureSource.quickCapture,
    );
    final resolvedStatus = CaptureStatus.values.firstWhere(
      (value) => value.name == status,
      orElse: () => CaptureStatus.inbox,
    );

    return CaptureItem.create(
      id: EntityId(id),
      content: content,
      context: CaptureContext(
        source: resolvedSource,
        channel: channel,
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: resolvedStatus,
      metadata: metadata,
    );
  }
}

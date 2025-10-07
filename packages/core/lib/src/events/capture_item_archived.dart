import 'package:cascade_flow_core/src/domain_event.dart';
import 'package:cascade_flow_core/src/value_objects/entity_id.dart';
import 'package:cascade_flow_core/src/value_objects/timestamp.dart';

/// Event emitted when a capture item is archived.
class CaptureItemArchived extends DomainEvent {
  /// Builds an event describing an archived capture item.
  factory CaptureItemArchived({
    required EntityId captureId,
    required String summary,
    Timestamp? occurredOn,
    EntityId? eventId,
  }) {
    final normalizedSummary = summary.trim();
    assert(normalizedSummary.isNotEmpty, 'summary cannot be empty');
    return CaptureItemArchived._(
      captureId: captureId,
      summary: normalizedSummary,
      eventId: eventId,
      occurredOn: occurredOn,
    );
  }

  CaptureItemArchived._({
    required this.captureId,
    required this.summary,
    super.eventId,
    super.occurredOn,
  });

  /// Identifier of the capture item that was archived.
  final EntityId captureId;

  /// Short description of the captured content.
  final String summary;

  @override
  String get type => 'capture.item.archived';
}

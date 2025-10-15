import 'package:cascade_flow_core/src/domain_event.dart';
import 'package:cascade_flow_core/src/value_objects/entity_id.dart';
import 'package:cascade_flow_core/src/value_objects/timestamp.dart';

/// Domain event indicating a capture item has been filed.
class CaptureItemFiled extends DomainEvent {
  /// Builds an event describing a newly filed capture item.
  factory CaptureItemFiled({
    required EntityId captureId,
    required String summary,
    Timestamp? occurredOn,
    EntityId? eventId,
  }) {
    final normalizedSummary = summary.trim();
    assert(normalizedSummary.isNotEmpty, 'summary cannot be empty');
    return CaptureItemFiled._(
      captureId: captureId,
      summary: normalizedSummary,
      eventId: eventId,
      occurredOn: occurredOn,
    );
  }

  /// Internal constructor that allows passing pre-validated data.
  CaptureItemFiled._({
    required this.captureId,
    required this.summary,
    super.eventId,
    super.occurredOn,
  });

  /// Identifier of the capture item that was filed.
  final EntityId captureId;

  /// Short description of the captured content.
  final String summary;

  @override
  String get type => 'capture.item.filed';
}

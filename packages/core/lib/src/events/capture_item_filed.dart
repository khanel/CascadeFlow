import '../domain_event.dart';
import '../value_objects/entity_id.dart';
import '../value_objects/timestamp.dart';

/// Event emitted when a capture item is filed into the inbox.
class CaptureItemFiled extends DomainEvent {
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

  CaptureItemFiled._({
    required this.captureId,
    required this.summary,
    EntityId? eventId,
    Timestamp? occurredOn,
  }) : super(eventId: eventId, occurredOn: occurredOn);

  /// Identifier of the capture item that was filed.
  final EntityId captureId;

  /// Short description of the captured content.
  final String summary;

  @override
  String get type => 'capture.item.filed';
}

import '../domain_event.dart';
import '../value_objects/entity_id.dart';
import '../value_objects/timestamp.dart';

/// Event emitted when a capture item is filed into the inbox.
class CaptureItemFiled extends DomainEvent {
  CaptureItemFiled({
    required this.captureId,
    required this.summary,
    Timestamp? occurredOn,
    EntityId? eventId,
  }) : super(eventId: eventId, occurredOn: occurredOn);

  /// Identifier of the capture item that was filed.
  final EntityId captureId;

  /// Short description of the captured content.
  final String summary;

  @override
  String get type => 'capture.item.filed';
}

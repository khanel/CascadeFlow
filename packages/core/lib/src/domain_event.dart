import 'package:cascade_flow_core/src/value_objects/entity_id.dart';
import 'package:cascade_flow_core/src/value_objects/timestamp.dart';

/// Base contract for domain events emitted by vertical slices.
abstract class DomainEvent {
  /// Creates a domain event with optional identifiers for testing.
  DomainEvent({
    EntityId? eventId,
    Timestamp? occurredOn,
  }) : eventId = eventId ?? EntityId.generate(),
       occurredOn = occurredOn ?? Timestamp.now();

  /// Unique identifier for this event instance.
  final EntityId eventId;

  /// Moment when the event occurred (UTC).
  final Timestamp occurredOn;

  /// Structured identifier consumers use to route the event.
  String get type;
}

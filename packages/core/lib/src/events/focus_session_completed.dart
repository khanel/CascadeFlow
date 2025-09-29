import '../domain_event.dart';
import '../value_objects/entity_id.dart';
import '../value_objects/timestamp.dart';

/// Event emitted when a focus session concludes.
class FocusSessionCompleted extends DomainEvent {
  FocusSessionCompleted({
    required this.sessionId,
    required this.duration,
    Timestamp? completedAt,
    EntityId? eventId,
    Timestamp? occurredOn,
  })  : completedAt = completedAt ?? Timestamp.now(),
        super(eventId: eventId, occurredOn: occurredOn ?? completedAt);

  /// Identifier of the focus session that completed.
  final EntityId sessionId;

  /// Total duration of the session.
  final Duration duration;

  /// Moment the session ended.
  final Timestamp completedAt;

  @override
  String get type => 'focus.session.completed';
}

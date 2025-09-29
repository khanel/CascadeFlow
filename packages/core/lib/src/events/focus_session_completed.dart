import '../domain_event.dart';
import '../value_objects/entity_id.dart';
import '../value_objects/timestamp.dart';

/// Event emitted when a focus session concludes.
class FocusSessionCompleted extends DomainEvent {
  factory FocusSessionCompleted({
    required EntityId sessionId,
    required Duration duration,
    Timestamp? completedAt,
    EntityId? eventId,
    Timestamp? occurredOn,
  }) {
    assert(!duration.isNegative, 'duration cannot be negative');
    final resolvedCompletedAt = completedAt ?? Timestamp.now();
    final resolvedOccurredOn = occurredOn ?? resolvedCompletedAt;
    return FocusSessionCompleted._(
      sessionId: sessionId,
      duration: duration,
      completedAt: resolvedCompletedAt,
      eventId: eventId,
      occurredOn: resolvedOccurredOn,
    );
  }

  FocusSessionCompleted._({
    required this.sessionId,
    required this.duration,
    required this.completedAt,
    EntityId? eventId,
    required Timestamp occurredOn,
  }) : super(eventId: eventId, occurredOn: occurredOn);

  /// Identifier of the focus session that completed.
  final EntityId sessionId;

  /// Total duration of the session.
  final Duration duration;

  /// Moment the session ended.
  final Timestamp completedAt;

  @override
  String get type => 'focus.session.completed';
}

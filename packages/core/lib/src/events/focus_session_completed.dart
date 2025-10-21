import 'package:cascade_flow_core/src/domain_event.dart';
import 'package:cascade_flow_core/src/value_objects/entity_id.dart';
import 'package:cascade_flow_core/src/value_objects/timestamp.dart';

/// Event emitted when a focus session concludes.
class FocusSessionCompleted extends DomainEvent {
  /// Builds an event emitted after a focus session ends.
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

  /// Internal constructor that wires values into the base event.
  FocusSessionCompleted._({
    required this.sessionId,
    required this.duration,
    required this.completedAt,
    required Timestamp super.occurredOn,
    super.eventId,
  });

  /// Identifier of the focus session that completed.
  final EntityId sessionId;

  /// Total duration of the session.
  final Duration duration;

  /// Moment the session ended.
  final Timestamp completedAt;

  @override
  String get type => 'focus.session.completed';
}

import 'package:collection/collection.dart' show MapEquality, UnmodifiableMapView;
import 'package:meta/meta.dart';

/// High-level facade wrapping notification scheduling operations.
class NotificationFacade {
  /// Creates a facade that delegates notification operations to [scheduler].
  NotificationFacade({required NotificationScheduler scheduler})
      : _scheduler = scheduler;

  final NotificationScheduler _scheduler;

  /// Schedule a notification via the configured scheduler.
  Future<void> schedule(NotificationRequest request) =>
      _scheduler.schedule(request);

  /// Cancel a scheduled notification.
  Future<void> cancel(String notificationId) =>
      _scheduler.cancel(notificationId);

  /// Clear all scheduled notifications.
  Future<void> clearAll() => _scheduler.clearAll();
}

/// Abstraction responsible for scheduling notifications on the platform.
abstract class NotificationScheduler {
  /// Enqueue a notification for delivery at the configured trigger time.
  Future<void> schedule(NotificationRequest request);

  /// Cancel a previously scheduled notification by its [notificationId].
  Future<void> cancel(String notificationId);

  /// Remove every scheduled notification managed by this scheduler.
  Future<void> clearAll();
}

/// Immutable request describing a notification delivery.
@immutable
class NotificationRequest {
  /// Builds a request ensuring payload immutability and UTC semantics.
  NotificationRequest({
    required this.id,
    required this.channel,
    required Map<String, Object?> payload,
    required DateTime triggerAt,
  })  : payload =
            UnmodifiableMapView(Map<String, Object?>.from(payload)),
        triggerAt = triggerAt.toUtc();

  /// Unique identifier for the notification.
  final String id;

  /// Channel determining the notification surface/audience.
  final NotificationChannel channel;

  /// Arbitrary payload delivered alongside the notification.
  final Map<String, Object?> payload;

  /// UTC instant when the notification should fire.
  final DateTime triggerAt;

  static const MapEquality<String, Object?> _payloadEquality =
      MapEquality<String, Object?>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationRequest &&
        other.id == id &&
        other.channel == channel &&
        other.triggerAt == triggerAt &&
        _payloadEquality.equals(other.payload, payload);
  }

  @override
  int get hashCode => Object.hash(
        id,
        channel,
        triggerAt,
        _payloadEquality.hash(payload),
      );

  @override
  String toString() =>
      'NotificationRequest(id: $id, channel: $channel, triggerAt: $triggerAt)';
}

/// Channels supported by the infrastructure layer.
enum NotificationChannel {
  /// Focus timer notifications (start/break/pause reminders).
  focus,

  /// Scheduling reminders for planned calendar blocks.
  schedule,

  /// Habit nudges targeting cadence/streak maintenance.
  habits,

  /// Review prompts requesting weekly/monthly reflections.
  review,

  /// Insights surfaced from analytics or event fabric.
  insights,
}

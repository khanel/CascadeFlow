import 'package:cascade_flow_core/cascade_flow_core.dart';

/// High-level facade wrapping notification scheduling operations.
class NotificationFacade {
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
  Future<void> schedule(NotificationRequest request);

  Future<void> cancel(String notificationId);

  Future<void> clearAll();
}

/// Immutable request describing a notification delivery.
class NotificationRequest {
  const NotificationRequest({
    required this.id,
    required this.channel,
    required this.payload,
    required this.triggerAt,
  });

  final String id;
  final NotificationChannel channel;
  final Map<String, Object?> payload;
  final DateTime triggerAt;
}

/// Channels supported by the infrastructure layer.
enum NotificationChannel {
  focus,
  schedule,
  habits,
  review,
  insights,
}

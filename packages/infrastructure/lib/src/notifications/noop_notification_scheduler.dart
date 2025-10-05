import 'package:cascade_flow_infrastructure/src/notifications/notification_facade.dart';

/// Scheduler stub used until platform integrations land.
class NoopNotificationScheduler implements NotificationScheduler {
  /// Creates a scheduler that intentionally performs no work.
  const NoopNotificationScheduler();

  @override
  Future<void> schedule(NotificationRequest request) async {}

  @override
  Future<void> cancel(String notificationId) async {}

  @override
  Future<void> clearAll() async {}
}

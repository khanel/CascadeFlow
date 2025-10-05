import 'package:cascade_flow_infrastructure/notifications.dart';

/// Scheduler stub used until platform integrations land.
class NoopNotificationScheduler implements NotificationScheduler {
  const NoopNotificationScheduler();

  @override
  Future<void> schedule(NotificationRequest request) async {}

  @override
  Future<void> cancel(String notificationId) async {}

  @override
  Future<void> clearAll() async {}
}

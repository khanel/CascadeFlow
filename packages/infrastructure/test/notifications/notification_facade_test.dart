import 'package:cascade_flow_infrastructure/notifications.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationFacade', () {
    test('exposes schedule, cancel and clear operations', () {
      // Arrange
      final facade = NotificationFacade(
        scheduler: FakeNotificationScheduler(),
      );

      // Act

      // Assert
      expect(facade.schedule, isNotNull);
      expect(facade.cancel, isNotNull);
      expect(facade.clearAll, isNotNull);
    });

    test(
        'delegates schedule requests to provided scheduler abstraction',
        () async {
      // Arrange
      final scheduler = RecordingNotificationScheduler();
      final facade = NotificationFacade(scheduler: scheduler);
      final request = NotificationRequest(
        id: 'focus_break',
        channel: NotificationChannel.focus,
        payload: const {'duration': '25m'},
        triggerAt: DateTime.utc(2025, 10, 1, 12),
      );

      // Act
      await facade.schedule(request);

      // Assert
      expect(scheduler.recordedRequests, hasLength(1));
      expect(scheduler.recordedRequests.single.id, 'focus_break');
    });

    test('supports cancel and clear operations through scheduler', () async {
      // Arrange
      final scheduler = RecordingNotificationScheduler();
      final facade = NotificationFacade(scheduler: scheduler);
      const id = 'focus_break';

      // Act
      await facade.cancel(id);
      await facade.clearAll();

      // Assert
      expect(scheduler.cancelledIds, contains(id));
      expect(scheduler.cleared, isTrue);
    });
  });
}

class FakeNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> schedule(NotificationRequest request) async {}

  @override
  Future<void> cancel(String notificationId) async {}

  @override
  Future<void> clearAll() async {}
}

class RecordingNotificationScheduler implements NotificationScheduler {
  final List<NotificationRequest> recordedRequests = [];
  final List<String> cancelledIds = [];
  bool cleared = false;

  @override
  Future<void> schedule(NotificationRequest request) async {
    recordedRequests.add(request);
  }

  @override
  Future<void> cancel(String notificationId) async {
    cancelledIds.add(notificationId);
  }

  @override
  Future<void> clearAll() async {
    cleared = true;
  }
}

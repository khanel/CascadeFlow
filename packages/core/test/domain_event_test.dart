import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:test/test.dart';

void main() {
  group('DomainEvent', () {
    test('assigns defaults for id and timestamp', () {
      // Act
      final event = CaptureItemFiled(
        captureId: EntityId('capture123'),
        summary: 'Captured an idea',
      );

      // Assert
      expect(event.eventId.value, hasLength(24));
      expect(event.occurredOn.value.isUtc, isTrue);
      expect(event.type, 'capture.item.filed');
    });

    test('accepts provided values', () {
      // Arrange
      final occurredOn = Timestamp(DateTime.utc(2025, 1, 1));
      final eventId = EntityId('event-123');

      // Act
      final event = FocusSessionCompleted(
        sessionId: EntityId('session-1'),
        duration: const Duration(minutes: 25),
        completedAt: occurredOn,
        eventId: eventId,
        occurredOn: occurredOn,
      );

      // Assert
      expect(event.eventId, equals(eventId));
      expect(event.completedAt, equals(occurredOn));
      expect(event.occurredOn, equals(occurredOn));
      expect(event.duration, const Duration(minutes: 25));
      expect(event.type, 'focus.session.completed');
    });
  });
}

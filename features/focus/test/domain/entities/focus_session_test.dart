import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_focus/focus.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FocusSession', () {
    test(
      'should create a focus session with default 90-minute duration',
      () {
        // Arrange & Act
        final session = FocusSession(
          id: EntityId('test-id'),
          title: 'Deep Work Session',
        );

        // Assert
        expect(session.durationMinutes, equals(90));
        expect(session.title, equals('Deep Work Session'));
        expect(session.status, equals(FocusSessionStatus.scheduled));
      },
    );

    test(
      'should transition from scheduled to active when started',
      () {
        // Arrange
        final session = FocusSession(
          id: EntityId('test-id'),
          title: 'Deep Work Session',
        );

        // Act - Simulate session start without real time delays
        final startedSession = session.start();

        // Assert
        expect(startedSession.status, equals(FocusSessionStatus.active));
        expect(startedSession.startedAt, isNotNull);
      },
    );

    test(
      'should calculate remaining time based on current status',
      () {
        fakeAsync((async) {
          // Arrange
          final session = FocusSession(
            id: EntityId('test-id'),
            title: 'Deep Work Session',
          );

          // Act & Assert - Test logical time calculations without real delays
          expect(session.remainingMinutes, equals(90));

          // Simulate active session with elapsed time
          final activeSession = session.start();

          // Advance time by 30 minutes to simulate elapsed session time
          async.elapse(const Duration(minutes: 30));

          // Verify remaining time calculation after 30 minutes
          expect(activeSession.remainingMinutes, equals(60));
          expect(activeSession.status, equals(FocusSessionStatus.active));
        });
      },
    );

    test(
      'should transition to completed when session finishes',
      () {
        fakeAsync((async) {
          // Arrange
          final session = FocusSession(
            id: EntityId('test-id'),
            title: 'Deep Work Session',
          ).start();

          // Act - Advance time to session completion (90 minutes)
          async.elapse(const Duration(minutes: 90));

          // Simulate completion check
          // (would be triggered by timer in real implementation)
          final completedSession = session.complete();

          // Assert
          expect(completedSession.status, equals(FocusSessionStatus.completed));
          expect(completedSession.completedAt, isNotNull);
        });
      },
    );

    test(
      'should allow pausing and resuming sessions',
      () {
        fakeAsync((async) {
          // Arrange
          final session = FocusSession(
            id: EntityId('test-id'),
            title: 'Deep Work Session',
          ).start();

          // Advance time by 15 minutes before pausing
          async.elapse(const Duration(minutes: 15));

          // Act - Pause session
          final pausedSession = session.pause();

          // Assert
          expect(pausedSession.status, equals(FocusSessionStatus.paused));
          expect(pausedSession.remainingMinutes, equals(75)); // 90 - 15

          // Advance time by 10 minutes while paused
          //(should not affect remaining time)
          async.elapse(const Duration(minutes: 10));

          // Act - Resume session
          final resumedSession = pausedSession.resume();

          // Assert
          expect(resumedSession.status, equals(FocusSessionStatus.active));
          expect(
            resumedSession.remainingMinutes,
            equals(75),
          ); // Still 75, pause time ignored
        });
      },
    );

    test(
      'should validate session duration within acceptable bounds',
      () {
        // Test minimum duration
        expect(
          () => FocusSession(
            id: EntityId('test-id'),
            title: 'Short Session',
            durationMinutes: 15,
          ),
          returnsNormally,
        );

        // Test maximum duration
        expect(
          () => FocusSession(
            id: EntityId('test-id'),
            title: 'Long Session',
            durationMinutes: 480, // 8 hours
          ),
          returnsNormally,
        );
      },
    );

    test(
      'should handle 30-minute timer completion without real time delay',
      () {
        fakeAsync((async) {
          // Arrange - Create a 30-minute session
          final session = FocusSession(
            id: EntityId('30min-test'),
            title: '30-Minute Focus Session',
            durationMinutes: 30,
          ).start();

          // Act - Advance time by exactly 30 minutes
          async.elapse(const Duration(minutes: 30));

          // Assert - Session should be completable after 30 minutes
          expect(session.remainingMinutes, equals(0));

          // Complete the session
          final completedSession = session.complete();
          expect(completedSession.status, equals(FocusSessionStatus.completed));
        });
      },
    );
  });
}

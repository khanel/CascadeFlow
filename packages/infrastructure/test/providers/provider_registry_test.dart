// Confirms provider wiring remains aligned with the Milestone 3 stubs outlined
// in `docs/project/progress.md`.
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:cascade_flow_infrastructure/notifications.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('Provider registry', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('loggerProvider returns a PrintLogger singleton', () {
      // Arrange
      final read = container.read;

      // Act
      final logger = read(loggerProvider);
      final loggerAgain = read(loggerProvider);

      // Assert
      expect(logger, isA<PrintLogger>());
      expect(identical(logger, loggerAgain), isTrue);
    });

    test(
      'hiveInitializerProvider returns in-memory initializer by default',
      () {
        // Arrange
        final read = container.read;

        // Act
        final initializer = read(hiveInitializerProvider);

        // Assert
        expect(initializer, isA<InMemoryHiveInitializer>());
      },
    );

    test('notificationSchedulerProvider exposes NotificationScheduler', () {
      // Arrange
      final read = container.read;

      // Act
      final scheduler = read(notificationSchedulerProvider);

      // Assert
      expect(scheduler, isA<NotificationScheduler>());
    });

    test('focusNotificationFacadeProvider returns singleton facade', () {
      // Arrange
      final read = container.read;

      // Act
      final facade = read(focusNotificationFacadeProvider);
      final facadeAgain = read(focusNotificationFacadeProvider);

      // Assert
      expect(facade, isA<NotificationFacade>());
      expect(identical(facade, facadeAgain), isTrue);
    });

    test('scheduleNotificationFacadeProvider returns singleton facade', () {
      // Arrange
      final read = container.read;

      // Act
      final facade = read(scheduleNotificationFacadeProvider);
      final facadeAgain = read(scheduleNotificationFacadeProvider);

      // Assert
      expect(facade, isA<NotificationFacade>());
      expect(identical(facade, facadeAgain), isTrue);
    });

    test('habitNotificationFacadeProvider returns singleton facade', () {
      // Arrange
      final read = container.read;

      // Act
      final facade = read(habitNotificationFacadeProvider);
      final facadeAgain = read(habitNotificationFacadeProvider);

      // Assert
      expect(facade, isA<NotificationFacade>());
      expect(identical(facade, facadeAgain), isTrue);
    });

    test('notificationBootstrapperProvider exposes bootstrap function', () {
      // Arrange
      final read = container.read;

      // Act
      final bootstrapper = read(notificationBootstrapperProvider);

      // Assert
      expect(bootstrapper, isA<Future<void> Function()>());
    });
  });
}

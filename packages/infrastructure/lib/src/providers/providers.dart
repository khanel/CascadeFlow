import 'package:cascade_flow_infrastructure/logging.dart';
import 'package:cascade_flow_infrastructure/notifications.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:riverpod/riverpod.dart';

import '../notifications/noop_notification_scheduler.dart';

/// Provides the shared [PrintLogger] used across the app and infrastructure.
final loggerProvider = Provider<PrintLogger>(
  (ref) => const PrintLogger(),
);

/// Provides the in-memory Hive initializer stub for early development.
final hiveInitializerProvider = Provider<InMemoryHiveInitializer>(
  (ref) => InMemoryHiveInitializer(),
);

/// Provides a disposable secure storage stub backed by an in-memory map.
final secureStorageProvider = Provider<InMemorySecureStorage>(
  (ref) => InMemorySecureStorage(),
);

/// Provides the scheduler used by notification facades. Stubbed until
/// platform integrations land.
final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => const NoopNotificationScheduler(),
);

/// Schedules focus-related notifications (Pomodoro timers, breaks, etc.).
final focusNotificationFacadeProvider = Provider<NotificationFacade>(
  (ref) => NotificationFacade(
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

/// Schedules reminders for upcoming calendar and plan blocks.
final scheduleNotificationFacadeProvider = Provider<NotificationFacade>(
  (ref) => NotificationFacade(
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

/// Schedules habit cadence nudges and streak reinforcement notifications.
final habitNotificationFacadeProvider = Provider<NotificationFacade>(
  (ref) => NotificationFacade(
    scheduler: ref.watch(notificationSchedulerProvider),
  ),
);

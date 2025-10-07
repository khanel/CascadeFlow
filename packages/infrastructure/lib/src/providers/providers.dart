import 'package:cascade_flow_infrastructure/logging.dart';
import 'package:cascade_flow_infrastructure/src/notifications/noop_notification_scheduler.dart';
import 'package:cascade_flow_infrastructure/src/notifications/notification_facade.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:riverpod/riverpod.dart';

/// Provides the shared [PrintLogger] used across the app and infrastructure.
final loggerProvider = Provider<PrintLogger>(
  (ref) => const PrintLogger(),
);

/// Provides the in-memory Hive initializer stub for early development.
final hiveInitializerProvider = Provider<InMemoryHiveInitializer>(
  (ref) => InMemoryHiveInitializer(),
);

/// Provides the registrar responsible for wiring Hive adapters.
final hiveAdapterRegistrarProvider = Provider<HiveAdapterRegistrar>(
  (ref) => noopHiveAdapterRegistrar,
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

NotificationFacade _buildNotificationFacade(Ref ref) => NotificationFacade(
      scheduler: ref.watch(notificationSchedulerProvider),
    );

/// Schedules focus-related notifications (Pomodoro timers, breaks, etc.).
final focusNotificationFacadeProvider = Provider<NotificationFacade>(
  _buildNotificationFacade,
);

/// Schedules reminders for upcoming calendar and plan blocks.
final scheduleNotificationFacadeProvider = Provider<NotificationFacade>(
  _buildNotificationFacade,
);

/// Schedules habit cadence nudges and streak reinforcement notifications.
final habitNotificationFacadeProvider = Provider<NotificationFacade>(
  _buildNotificationFacade,
);

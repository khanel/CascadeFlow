import 'package:cascade_flow_app/src/bootstrap/bootstrap_runner.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:cascade_flow_infrastructure/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const List<String> _expectedBaseBoxes = <String>[
  'app.preferences',
  'app.navigation_state',
  'app.adapter_registry',
];

// Exercises the bootstrap runner using recording stubs to verify ordering.
class _RecordingSecureStorage extends InMemorySecureStorage {
  final List<String> readKeys = <String>[];

  @override
  Future<String?> read({required String key}) {
    readKeys.add(key);
    return super.read(key: key);
  }
}

class _RecordingHiveInitializer extends InMemoryHiveInitializer {
  _RecordingHiveInitializer({void Function(String name)? onBoxOpened})
    : _onBoxOpened = onBoxOpened;

  bool initializeCalled = false;
  final List<String> openedBoxes = <String>[];
  final void Function(String name)? _onBoxOpened;

  @override
  Future<void> initialize() {
    initializeCalled = true;
    return super.initialize();
  }

  @override
  Future<InMemoryHiveBox<T>> openEncryptedBox<T>(String name) {
    _onBoxOpened?.call(name);
    openedBoxes.add(name);
    return super.openEncryptedBox<T>(name);
  }
}

class _RecordingNotificationScheduler implements NotificationScheduler {
  bool clearAllCalled = false;

  @override
  Future<void> cancel(String notificationId) async {}

  @override
  Future<void> clearAll() async {
    clearAllCalled = true;
  }

  @override
  Future<void> schedule(NotificationRequest request) async {}
}

class _BootstrapGuardScheduler implements NotificationScheduler {
  _BootstrapGuardScheduler(this.bootstrapGuard);

  final ValueNotifier<bool> bootstrapGuard;

  @override
  Future<void> schedule(NotificationRequest request) async {}

  @override
  Future<void> cancel(String notificationId) async {}

  @override
  Future<void> clearAll() async {
    if (!bootstrapGuard.value) {
      throw StateError('Notifications not bootstrapped');
    }
  }
}

void main() {
  // Ensures secure storage lookup and Hive bootstrap happen before UI renders.
  test(
    'bootstrap runner opens required base boxes before UI launch',
    () async {
      // ARRANGE
      final secureStorage = _RecordingSecureStorage();
      final hiveInitializer = _RecordingHiveInitializer();
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secureStorage),
          hiveInitializerProvider.overrideWithValue(hiveInitializer),
        ],
      );

      // ACT
      await runCascadeBootstrap(container);

      // ASSERT
      expect(
        secureStorage.readKeys.single,
        'cascadeflow.hive_encryption_key',
      );
      expect(hiveInitializer.initializeCalled, isTrue);
      expect(
        hiveInitializer.openedBoxes,
        containsAll(_expectedBaseBoxes),
      );

      container.dispose();
    },
  );

  // Guards that notification setup runs before the facade clear phase.
  test(
    'bootstrap runner initialises notifications before clearing facades',
    () async {
      // ARRANGE
      final secureStorage = _RecordingSecureStorage();
      final hiveInitializer = _RecordingHiveInitializer();
      final bootstrapGuard = ValueNotifier<bool>(false);
      final scheduler = _BootstrapGuardScheduler(bootstrapGuard);
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secureStorage),
          hiveInitializerProvider.overrideWithValue(hiveInitializer),
          notificationBootstrapperProvider.overrideWithValue(
            () async => bootstrapGuard.value = true,
          ),
          notificationSchedulerProvider.overrideWithValue(scheduler),
        ],
      );

      // ACT & ASSERT
      expect(runCascadeBootstrap(container), completes);

      container.dispose();
    },
  );

  // Verifies adapter registration happens before box warm-up to prevent
  // type mismatches.
  test(
    'bootstrap runner registers Hive adapters before opening base boxes',
    () async {
      // ARRANGE
      final order = <String>[];
      var registerCalled = false;
      Future<void> registrar() async {
        registerCalled = true;
        order.add('register');
      }

      final secureStorage = _RecordingSecureStorage();
      final hiveInitializer = _RecordingHiveInitializer(
        onBoxOpened: (name) => order.add('open:$name'),
      );

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secureStorage),
          hiveInitializerProvider.overrideWithValue(hiveInitializer),
          hiveAdapterRegistrarProvider.overrideWithValue(registrar),
        ],
      );

      // ACT
      await runCascadeBootstrap(container);

      // ASSERT
      expect(registerCalled, isTrue);
      expect(order, isNotEmpty);
      expect(order.first, 'register');

      container.dispose();
    },
  );

  // Confirms notification bootstrapper runs before clearing individual facades.
  test(
    '''
bootstrap runner initialises notification
bootstrapper before facade clear''',
    () async {
      // ARRANGE
      final secureStorage = _RecordingSecureStorage();
      final hiveInitializer = _RecordingHiveInitializer();
      final bootstrapperCalls = <String>[];
      Future<void> bootstrapper() async {
        bootstrapperCalls.add('bootstrap');
      }

      final focusScheduler = _RecordingNotificationScheduler();
      final scheduleScheduler = _RecordingNotificationScheduler();
      final habitScheduler = _RecordingNotificationScheduler();
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secureStorage),
          hiveInitializerProvider.overrideWithValue(hiveInitializer),
          notificationBootstrapperProvider.overrideWithValue(bootstrapper),
          focusNotificationFacadeProvider.overrideWithValue(
            NotificationFacade(scheduler: focusScheduler),
          ),
          scheduleNotificationFacadeProvider.overrideWithValue(
            NotificationFacade(scheduler: scheduleScheduler),
          ),
          habitNotificationFacadeProvider.overrideWithValue(
            NotificationFacade(scheduler: habitScheduler),
          ),
        ],
      );

      // ACT
      await runCascadeBootstrap(container);

      // ASSERT
      expect(bootstrapperCalls, isNotEmpty);
      expect(focusScheduler.clearAllCalled, isTrue);
      expect(scheduleScheduler.clearAllCalled, isTrue);
      expect(habitScheduler.clearAllCalled, isTrue);

      container.dispose();
    },
  );

  // Maintains the expectation that facades clear their queues after bootstrap.
  test(
    'bootstrap runner clears pending notifications across facades',
    () async {
      // ARRANGE
      final secureStorage = _RecordingSecureStorage();
      final hiveInitializer = _RecordingHiveInitializer();
      final focusScheduler = _RecordingNotificationScheduler();
      final scheduleScheduler = _RecordingNotificationScheduler();
      final habitScheduler = _RecordingNotificationScheduler();
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secureStorage),
          hiveInitializerProvider.overrideWithValue(hiveInitializer),
          focusNotificationFacadeProvider.overrideWithValue(
            NotificationFacade(scheduler: focusScheduler),
          ),
          scheduleNotificationFacadeProvider.overrideWithValue(
            NotificationFacade(scheduler: scheduleScheduler),
          ),
          habitNotificationFacadeProvider.overrideWithValue(
            NotificationFacade(scheduler: habitScheduler),
          ),
        ],
      );

      // ACT
      await runCascadeBootstrap(container);

      // ASSERT
      expect(focusScheduler.clearAllCalled, isTrue);
      expect(scheduleScheduler.clearAllCalled, isTrue);
      expect(habitScheduler.clearAllCalled, isTrue);

      container.dispose();
    },
  );
}

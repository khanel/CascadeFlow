import 'package:cascade_flow_app/src/bootstrap/bootstrap_runner.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:cascade_flow_infrastructure/notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const List<String> _expectedBaseBoxes = <String>[
  'app.preferences',
  'app.navigation_state',
  'app.adapter_registry',
];

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

void main() {
  test(
    'bootstrap runner opens required base boxes before UI launch',
    () async {
      final secureStorage = _RecordingSecureStorage();
      final hiveInitializer = _RecordingHiveInitializer();

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secureStorage),
          hiveInitializerProvider.overrideWithValue(hiveInitializer),
        ],
      );

      await runCascadeBootstrap(container);

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

  test(
    'bootstrap runner registers Hive adapters before opening base boxes',
    () async {
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

      await runCascadeBootstrap(container);

      expect(registerCalled, isTrue);
      expect(order, isNotEmpty);
      expect(order.first, 'register');

      container.dispose();
    },
  );

  test(
    'bootstrap runner clears pending notifications across facades',
    () async {
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

      await runCascadeBootstrap(container);

      expect(focusScheduler.clearAllCalled, isTrue);
      expect(scheduleScheduler.clearAllCalled, isTrue);
      expect(habitScheduler.clearAllCalled, isTrue);

      container.dispose();
    },
  );
}

import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage key used to retrieve the Hive encryption secret.
const String _hiveEncryptionKey = 'cascadeflow.hive_encryption_key';

/// Boxes the app shell expects to be ready before UI launch.
const List<String> _baseHiveBoxes = <String>[
  'app.preferences',
  'app.navigation_state',
  'app.adapter_registry',
];

/// Executes startup tasks required before rendering the app shell.
Future<void> runCascadeBootstrap(ProviderContainer container) async {
  final secureStorage = container.read(secureStorageProvider);
  final hiveInitializer = container.read(hiveInitializerProvider);
  final hiveAdapterRegistrar = container.read(hiveAdapterRegistrarProvider);
  final focusNotifications = container.read(focusNotificationFacadeProvider);
  final scheduleNotifications =
      container.read(scheduleNotificationFacadeProvider);
  final habitNotifications = container.read(habitNotificationFacadeProvider);

  final encryptionKeyFuture = secureStorage.read(key: _hiveEncryptionKey);
  final hiveInitializationFuture = hiveInitializer.initialize();

  await encryptionKeyFuture;
  await hiveInitializationFuture;
  await hiveAdapterRegistrar();

  await Future.wait<void>(
    _baseHiveBoxes.map(
      (boxName) async =>
          hiveInitializer.openEncryptedBox<dynamic>(boxName),
    ),
  );

  await Future.wait<void>(<Future<void>>[
    focusNotifications.clearAll(),
    scheduleNotifications.clearAll(),
    habitNotifications.clearAll(),
  ]);
}

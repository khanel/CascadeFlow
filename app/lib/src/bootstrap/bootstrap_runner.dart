import 'package:cascade_flow_app/src/bootstrap/hive_adapter_registration.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage key used to retrieve the Hive encryption secret.
const String _hiveEncryptionKey = 'cascadeflow.hive_encryption_key';

/// Registry key storing bootstrap metadata.
const String _adapterRegistryBootstrapKey = 'bootstrap';

/// Boxes the app shell expects to be ready before UI launch.
const List<String> _baseHiveBoxes = <String>[
  'app.preferences',
  'app.navigation_state',
];

/// Executes startup tasks required before rendering the app shell.
Future<void> runCascadeBootstrap(ProviderContainer container) async {
  final secureStorage = container.read(secureStorageProvider);
  final hiveInitializer = container.read(hiveInitializerProvider);
  final hiveAdapterRegistrar = container.read(hiveAdapterRegistrarProvider);
  final notificationBootstrapper = container.read(
    notificationBootstrapperProvider,
  );
  final focusNotifications = container.read(focusNotificationFacadeProvider);
  final scheduleNotifications = container.read(
    scheduleNotificationFacadeProvider,
  );
  final habitNotifications = container.read(habitNotificationFacadeProvider);

  final encryptionKeyFuture = secureStorage.read(key: _hiveEncryptionKey);
  final hiveInitializationFuture = hiveInitializer.initialize();

  await encryptionKeyFuture;
  await hiveInitializationFuture;
  await hiveAdapterRegistrar();

  await Future.wait<void>(
    _baseHiveBoxes.map(
      (boxName) => hiveInitializer.openEncryptedBox<dynamic>(boxName),
    ),
  );
  final adapterRegistryBox =
      await hiveInitializer.openEncryptedBox<Map<dynamic, dynamic>>(
        adapterRegistryBoxName,
      );
  await adapterRegistryBox.put(
    _adapterRegistryBootstrapKey,
    createAdapterRegistrationMetadata(),
  );

  await notificationBootstrapper();

  await Future.wait<void>(<Future<void>>[
    focusNotifications.clearAll(),
    scheduleNotifications.clearAll(),
    habitNotifications.clearAll(),
  ]);
}

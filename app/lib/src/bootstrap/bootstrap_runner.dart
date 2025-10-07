import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage key used to retrieve the Hive encryption secret.
const String _hiveEncryptionKey = 'cascadeflow.hive_encryption_key';

/// Executes startup tasks required before rendering the app shell.
Future<void> runCascadeBootstrap(ProviderContainer container) async {
  final secureStorage = container.read(secureStorageProvider);
  final hiveInitializer = container.read(hiveInitializerProvider);

  final encryptionKeyFuture = secureStorage.read(key: _hiveEncryptionKey);
  final hiveInitializationFuture = hiveInitializer.initialize();

  await encryptionKeyFuture;
  await hiveInitializationFuture;

  await hiveInitializer.openEncryptedBox<dynamic>('app.preferences');
  await hiveInitializer.openEncryptedBox<dynamic>('app.navigation_state');
}

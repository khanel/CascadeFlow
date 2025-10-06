import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _hiveEncryptionKey = 'cascadeflow.hive_encryption_key';

Future<void> runCascadeBootstrap(ProviderContainer container) async {
  final secureStorage = container.read(secureStorageProvider);
  final hiveInitializer = container.read(hiveInitializerProvider);

  await secureStorage.read(key: _hiveEncryptionKey);
  await hiveInitializer.initialize();
}

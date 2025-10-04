import 'package:cascade_flow_infrastructure/logging.dart';
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

/// Provides a disposable secure storage stub backed by an in-memory map.
final secureStorageProvider = Provider<InMemorySecureStorage>(
  (ref) => InMemorySecureStorage(),
);

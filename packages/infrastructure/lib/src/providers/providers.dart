import 'package:riverpod/riverpod.dart';

import '../logging/print_logger.dart';
import '../storage/in_memory_hive_initializer.dart';
import '../storage/in_memory_secure_storage.dart';

final loggerProvider = Provider<PrintLogger>((ref) {
  return const PrintLogger();
});

final hiveInitializerProvider = Provider<InMemoryHiveInitializer>((ref) {
  return InMemoryHiveInitializer();
});

final secureStorageProvider = Provider<InMemorySecureStorage>((ref) {
  return InMemorySecureStorage();
});

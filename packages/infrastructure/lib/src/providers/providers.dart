import 'package:riverpod/riverpod.dart';

import '../logging/print_logger.dart';
import '../storage/in_memory_hive_initializer.dart';
import '../storage/in_memory_secure_storage.dart';

final loggerProvider = Provider<PrintLogger>(
  (ref) => const PrintLogger(),
);

final hiveInitializerProvider = Provider<InMemoryHiveInitializer>(
  (ref) => InMemoryHiveInitializer(),
);

final secureStorageProvider = Provider<InMemorySecureStorage>(
  (ref) => InMemorySecureStorage(),
);

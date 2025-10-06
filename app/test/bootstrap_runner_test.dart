import 'package:cascade_flow_app/src/bootstrap/bootstrap_runner.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingSecureStorage extends InMemorySecureStorage {
  final List<String> readKeys = <String>[];

  @override
  Future<String?> read({required String key}) {
    readKeys.add(key);
    return super.read(key: key);
  }
}

class _RecordingHiveInitializer extends InMemoryHiveInitializer {
  bool initializeCalled = false;

  @override
  Future<void> initialize() {
    initializeCalled = true;
    return super.initialize();
  }
}

void main() {
  test(
    'bootstrap runner requests encryption key and initialises Hive',
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

    container.dispose();
  });
}

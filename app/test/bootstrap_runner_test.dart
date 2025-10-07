import 'package:cascade_flow_app/src/bootstrap/bootstrap_runner.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const List<String> _expectedBaseBoxes = <String>[
  'app.preferences',
  'app.navigation_state',
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
  bool initializeCalled = false;
  final List<String> openedBoxes = <String>[];

  @override
  Future<void> initialize() {
    initializeCalled = true;
    return super.initialize();
  }

  @override
  Future<InMemoryHiveBox<T>> openEncryptedBox<T>(String name) {
    openedBoxes.add(name);
    return super.openEncryptedBox<T>(name);
  }
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
}

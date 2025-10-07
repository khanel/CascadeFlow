import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingInitializer extends InMemoryHiveInitializer {
  final List<String> openedBoxes = <String>[];
  bool initializeCalled = false;

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
  test('warmUp initializes hive and opens capture inbox box', () async {
    // ARRANGE
    final initializer = _RecordingInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);

    // ACT
    await dataSource.warmUp();

    // ASSERT
    expect(initializer.initializeCalled, isTrue);
    expect(initializer.openedBoxes, contains(captureItemsBoxName));
    expect(initializer.openedBoxes.length, equals(1));
  });
}

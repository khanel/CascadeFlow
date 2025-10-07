import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingInitializer extends InMemoryHiveInitializer {
  final List<String> openedBoxes = <String>[];

  @override
  Future<InMemoryHiveBox<T>> openEncryptedBox<T>(String name) {
    openedBoxes.add(name);
    return super.openEncryptedBox<T>(name);
  }
}

void main() {
  test('warmUp opens capture inbox box', () async {
    // ARRANGE
    final initializer = _RecordingInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);

    // ACT
    await dataSource.warmUp();

    // ASSERT
    expect(initializer.openedBoxes, contains('capture_items')); // box name TBD
  });
}

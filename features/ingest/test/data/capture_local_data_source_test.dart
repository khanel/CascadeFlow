import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_utils/capture_test_data.dart';

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
    expect(
      initializer.openedBoxes,
      contains(captureItemsBoxName),
    );
    expect(initializer.openedBoxes.length, equals(1));
  });

  test('save writes capture model and read returns stored entry', () async {
    // ARRANGE
    final initializer = InMemoryHiveInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);
    await dataSource.warmUp();
    final item = buildTestCaptureItem(
      id: 'capture-1',
      createdMicros: 100,
      updatedMicros: 100,
    );
    final model = CaptureItemHiveModel.fromDomain(item);

    // ACT
    await dataSource.save(model);
    final stored = await dataSource.read(model.id);

    // ASSERT
    expect(stored, isNotNull);
    expect(stored!.toDomain(), equals(item));
  });

  test('readAll returns models in insertion order '
      'with latest values', () async {
    // ARRANGE
    final initializer = InMemoryHiveInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);
    await dataSource.warmUp();
    final first = CaptureItemHiveModel.fromDomain(
      buildTestCaptureItem(
        id: 'capture-a',
        createdMicros: 50,
        updatedMicros: 50,
      ),
    );
    final second = CaptureItemHiveModel.fromDomain(
      buildTestCaptureItem(
        id: 'capture-b',
        createdMicros: 60,
        updatedMicros: 60,
      ),
    );

    // ACT
    await dataSource.save(first);
    await dataSource.save(second);
    final models = await dataSource.readAll();

    // ASSERT
    expect(models, hasLength(2));
    expect(models.first.id, first.id);
    expect(models.last.id, second.id);
  });

  test('delete removes stored capture model and ignores unknown ids', () async {
    // ARRANGE
    final initializer = InMemoryHiveInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);
    await dataSource.warmUp();
    final model = CaptureItemHiveModel.fromDomain(
      buildTestCaptureItem(
        id: 'to-delete',
        createdMicros: 5,
        updatedMicros: 5,
      ),
    );
    await dataSource.save(model);

    // ACT
    await dataSource.delete(model.id);
    await dataSource.delete('missing-id');

    // ASSERT
    expect(await dataSource.read(model.id), isNull);
    final remaining = await dataSource.readAll();
    expect(remaining, isEmpty);
  });
}

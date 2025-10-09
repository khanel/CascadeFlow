import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
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

CaptureItem _buildCaptureItem({
  required String id,
  CaptureStatus status = CaptureStatus.inbox,
  String content = 'Capture content',
  String channel = 'quick_sheet',
  int createdMicros = 0,
  int updatedMicros = 0,
}) {
  return CaptureItem.create(
    id: EntityId(id),
    content: content,
    context: CaptureContext(
      source: CaptureSource.quickCapture,
      channel: channel,
    ),
    status: status,
    createdAt: Timestamp(DateTime.fromMicrosecondsSinceEpoch(
      createdMicros,
      isUtc: true,
    )),
    updatedAt: Timestamp(DateTime.fromMicrosecondsSinceEpoch(
      updatedMicros,
      isUtc: true,
    )),
  );
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

  test('save writes capture model and read returns stored entry', () async {
    // ARRANGE
    final initializer = InMemoryHiveInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);
    await dataSource.warmUp();
    final item = _buildCaptureItem(
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

  test('readAll returns models in insertion order with latest values', () async {
    // ARRANGE
    final initializer = InMemoryHiveInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);
    await dataSource.warmUp();
    final first = CaptureItemHiveModel.fromDomain(
      _buildCaptureItem(
        id: 'capture-a',
        createdMicros: 50,
        updatedMicros: 50,
      ),
    );
    final second = CaptureItemHiveModel.fromDomain(
      _buildCaptureItem(
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
}

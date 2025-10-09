import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:cascade_flow_ingest/data/repositories/capture_repository_impl.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:flutter_test/flutter_test.dart';

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
  late InMemoryHiveInitializer initializer;
  late CaptureLocalDataSource dataSource;
  late CaptureRepositoryImpl repository;

  setUp(() async {
    initializer = InMemoryHiveInitializer();
    dataSource = CaptureLocalDataSource(initializer: initializer);
    repository = CaptureRepositoryImpl(localDataSource: dataSource);
    await dataSource.warmUp();
  });

  test('save persists capture item to local data source', () async {
    // ARRANGE
    final item = _buildCaptureItem(
      id: 'capture-1',
      createdMicros: 100,
      updatedMicros: 100,
    );

    // ACT
    await repository.save(item);

    // ASSERT
    final persisted = await dataSource.read(item.id.value);
    expect(persisted?.toDomain(), equals(item));
  });

  test('loadInbox returns inbox items ordered by creation time', () async {
    // ARRANGE
    final older = _buildCaptureItem(
      id: 'capture-old',
      createdMicros: 10,
      updatedMicros: 10,
    );
    final archived = _buildCaptureItem(
      id: 'capture-archived',
      status: CaptureStatus.archived,
      createdMicros: 20,
      updatedMicros: 20,
    );
    final newer = _buildCaptureItem(
      id: 'capture-new',
      createdMicros: 30,
      updatedMicros: 30,
    );

    await repository.save(newer);
    await repository.save(archived);
    await repository.save(older);

    // ACT
    final inboxItems = await repository.loadInbox();

    // ASSERT
    expect(inboxItems, equals(<CaptureItem>[older, newer]));
  });

  test('save overwrites existing item preserving latest domain state', () async {
    // ARRANGE
    final seed = _buildCaptureItem(
      id: 'capture-update',
      createdMicros: 1,
      updatedMicros: 1,
    );
    await repository.save(seed);
    final archived = seed.copyWith(
      status: CaptureStatus.archived,
      updatedAt: Timestamp(DateTime.fromMicrosecondsSinceEpoch(
        5,
        isUtc: true,
      )),
    );

    // ACT
    await repository.save(archived);

    // ASSERT
    final stored = await dataSource.read(seed.id.value);
    expect(stored?.status, CaptureStatus.archived.name);
    final inboxItems = await repository.loadInbox();
    expect(inboxItems, isEmpty);
  });
}

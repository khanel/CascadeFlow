import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:cascade_flow_ingest/data/repositories/capture_repository_impl.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_utils/capture_test_data.dart';

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
    final item = buildTestCaptureItem(
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
    final older = buildTestCaptureItem(
      id: 'capture-old',
      createdMicros: 10,
      updatedMicros: 10,
    );
    final archived = buildTestCaptureItem(
      id: 'capture-archived',
      status: CaptureStatus.archived,
      createdMicros: 20,
      updatedMicros: 20,
    );
    final newer = buildTestCaptureItem(
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
    expect(
      inboxItems,
      equals(<CaptureItem>[older, newer]),
    );
  });

  test('save overwrites existing item '
      'preserving latest domain state', () async {
    // ARRANGE
    final seed = buildTestCaptureItem(
      id: 'capture-update',
      createdMicros: 1,
      updatedMicros: 1,
    );
    await repository.save(seed);
    final archived = seed.copyWith(status: CaptureStatus.archived);

    // ACT
    await repository.save(archived);

    // ASSERT
    final stored = await dataSource.read(seed.id.value);
    expect(stored?.status, CaptureStatus.archived.name);
    final inboxItems = await repository.loadInbox();
    expect(inboxItems, isEmpty);
  });

  test('delete removes capture from persistence and repository view', () async {
    // ARRANGE
    final first = buildTestCaptureItem(
      id: 'capture-first',
      createdMicros: 1,
      updatedMicros: 1,
    );
    final second = buildTestCaptureItem(
      id: 'capture-second',
      createdMicros: 2,
      updatedMicros: 2,
    );
    await repository.save(first);
    await repository.save(second);

    // ACT
    await repository.delete(first.id);

    // ASSERT
    expect(await dataSource.read(first.id.value), isNull);
    final inboxItems = await repository.loadInbox();
    expect(inboxItems, equals(<CaptureItem>[second]));
  });
}
